<!--
  payment-master-order-implementation-plan.md
  Medsy

  Created by Ahmed Elkady on 13/08/2026.
-->

# Payment and Master-Order Implementation Plan

## Objective

Finish the `feature/payment` branch against backend commit `ebee7cc` so the Medsy patient and pharmacy iOS apps correctly support:

- explicit delivery or pickup confirmation after offer selection;
- cash and Stripe card flows;
- pending-payment retry/resume/expiry behavior;
- customer master-order list, server filtering, details, and statuses;
- pharmacy post-payment sub-order list, details, filtering, and status actions;
- the complete lifecycle through backend status `DELIVERED`.

This plan is derived from [request-to-order-lifecycle.md](request-to-order-lifecycle.md).

## Scope boundaries

### In scope

- Patient `Offers`, `Payment`, and `Orders` features where needed to connect fulfillment, payment, and master orders.
- Pharmacy `Orders` feature where needed to consume post-selection sub-orders and update their statuses.
- Shared networking/DI/localization/test changes strictly required by those features.
- Defensive decoding/mapping for the latest backend response shapes.

### Out of scope

- Request creation/cart behavior except a contract regression discovered by payment/master-order integration.
- Pharmacy request discovery, request details, product search, or offer creation except navigation handoff into the new post-order flow.
- Authentication, profile, catalog, chatbot, promotions, or unrelated UI/theme refactors.
- Backend implementation changes.
- Reorder behavior except preserving the existing action on master-order details.

If an out-of-scope backend defect blocks these flows, document it with the exact endpoint and payload rather than changing another iOS feature.

## Current implementation assessment

### Comparison after merging `origin/development`

Compared on 13 August 2026 against iOS development commit `40fb81e` and backend
commit `ebee7cc`.

| Area | Latest development state | Remaining `feature/payment` work |
| --- | --- | --- |
| Request creation | Fulfillment is no longer selected or sent while creating a request. Delivery location and payment method remain in the request flow. | Keep this boundary; do not move fulfillment back into Complete Request. |
| Offer selection | `POST /requests/{id}/select` is separate and decodes request ID, pharmacy groups, coordinates, items, delivery fees, and total. | Replace raw `String` fulfillment values with a domain enum and replace direct `UserDefaults` handoff storage with scoped persistence if app-restart recovery is required. |
| Fulfillment confirmation | Order Review exposes delivery/pickup and calls `POST /requests/{id}/confirm`. | Preserve selection across a failed confirmation without repeating selection; add focused transition tests. |
| Payment handoff | Confirmation decodes master-order/payment fields, but development's mapper discards them and routes directly to completion. | Preserve those fields in `ConfirmOfferResult` and route through the existing Payment feature. |
| Patient master-order contract | List/detail decode exact statuses including `PENDING_PAYMENT` and `READY_FOR_DELIVERY`, master-level payment fields, pharmacy groups, coordinates, and localized product data. | Consolidate duplicate order/payment enums only if necessary; avoid widening scope while behavior remains correct. |
| Patient master-order UI | Details preserve pharmacy grouping, map delivery/pharmacy locations, show payment metadata, and understand the latest status progression. | Keep pending-card pay/retry/expired actions and refresh detail/list after payment. Add a list-card payment entry point if approved by product. |
| Patient filtering | Language, page, and size are sent; fulfillment/date/status groups are still filtered locally. | Add optional exact backend `status` filtering and make composite active pagination correct across all pages/statuses. |
| Pharmacy post-order flow | Pharmacy models were expanded, but Orders still reads `/pharmacies/requests` and uses decode fallback between assignment and order DTOs. | Implement the dedicated post-selection order endpoints and status transitions in Phases 6–7. |
| Stripe callback/configuration | Payment architecture, PaymentSheet, polling, app URL callback, and `medsy` URL scheme exist on the feature branch. | Validate retry/deadline/foreground behavior and keep the URL scheme while accepting development's microphone/speech plist keys. |

This merge means Phases 1, 2, and 5 are now substantially implemented by
`development`; they require integration hardening rather than a fresh rewrite.
Phases 3 and 4 remain partial, while Phases 6 and 7 remain the largest missing
implementation area.

### Already present and reusable

- Patient sends `CASH`/`CARD` during medicine-request creation.
- Offer selection uses `POST /requests/{id}/select`.
- Fulfillment confirmation uses a separate `POST /requests/{id}/confirm` call.
- Order Review already presents delivery/pickup and calculates the delivery fee conditionally.
- Selection decoding preserves fees, totals, pharmacy coordinates, and grouped items.
- Payment feature already has clean domain/data/presentation layers.
- Stripe PaymentSheet uses the server client secret.
- Payment status polling reads `GET /masterorders/{id}`.
- Patient order list/details already use master-order endpoints.
- Patient order details have the payment metadata required for a payment-resume action.
- English/Arabic payment strings and core payment tests exist.

### Required corrections

1. Fulfillment is still passed through the Offers domain chain as a raw `String`; use a typed delivery/pickup domain value.
2. Selection's JSON `offerId` remains named as an offer in iOS although it represents the created sub-order ID after selection.
3. Selection handoff state is stored directly in `UserDefaults`; define lifecycle, account scoping, cleanup, and app-restart behavior.
4. Development's fulfillment mapper discards `masterOrderId`, order status, payment method, and payment status, breaking the payment handoff unless restored.
5. Patient list filtering is entirely client-side although the backend supports one exact `status` query.
6. Current composite filtering can skip valid results because it filters each server page independently.
7. Pending payment should be reachable from both list and detail and must honor the server deadline consistently.
8. Pharmacy Orders still calls `/pharmacies/requests`, which is the request-assignment/offer flow rather than the post-payment order flow.
9. Pharmacy still retries decoding the same response as assignment and order DTOs instead of using a dedicated post-order contract.
10. Pharmacy list still hardcodes or infers payment behavior incorrectly.
11. Pharmacy order details reuse request-details presentation and have no live order-status actions.

## Target patient flow

```text
Order review
  -> POST /requests/{requestId}/select
  -> fulfillment choice (DELIVERY or PICKUP)
  -> POST /requests/{requestId}/confirm
      -> CASH: master order PREPARING -> order detail/success
      -> CARD: master order PENDING_PAYMENT -> PaymentSheet
          -> poll master order until PAID/PREPARING
          -> order detail/success
          -> cancelled/failed: retry while deadline remains
          -> expired: show expired and disable payment
```

## Target pharmacy flow

```text
Request assignments (/pharmacies/requests)
  -> submit offer

Post-selection orders (/orders/pharmacy/{pharmacyId})
  -> PREPARING
  -> READY_FOR_PICKUP or READY_FOR_DELIVERY
  -> OUT_FOR_DELIVERY (delivery only)
  -> DELIVERED
```

The two feeds must remain separate in code and UI because they represent different backend resources and user responsibilities.

## Implementation phases

### Phase 1: contract models and shared status vocabulary

Patient app:

- Replace duplicate/partial order-status representations with exact backend values:
  `PENDING`, `PENDING_PAYMENT`, `PREPARING`, `READY_FOR_PICKUP`,
  `READY_FOR_DELIVERY`, `OUT_FOR_DELIVERY`, `DELIVERED`, and `CANCELLED`.
- Remove unsupported `COMPLETED` from master-order logic or retain only as an explicitly unknown legacy decode path.
- Keep payment statuses exact, including the backend spelling `CANCELED`.
- Add a fulfillment domain type with `DELIVERY` and `PICKUP`.
- Model master-order pharmacy groups and their sub-order IDs explicitly.
- Decode the selection response's `deliveryFees`, `totalPrice`, pharmacy coordinates, and nested items.
- Rename the decoded selection key semantically: JSON `offerId` -> domain `subOrderId`.

Pharmacy app:

- Replace the current post-order DTO with the latest backend `OrderResponse` fields.
- Decode nested `product` summaries for localized name/image details.
- Add exact order, payment-method, and fulfillment-method domain enums.
- Remove fallback logic that interprets request assignments as pharmacy orders.

Tests:

- Add JSON fixtures matching current `ConfirmationResponse`, `FulfillmentConfirmationResponse`, `MasterOrderResponse`, paginated master-order response, and `OrderResponse`.
- Test all exact enum strings and nullable cash payment fields.
- Test `pageNumber`/`pageSize` pagination keys.

### Phase 2: split selection from fulfillment confirmation

Refactor the Offers dependency chain into two actions:

1. `ConfirmOfferSelectionUseCase`
   - sends only `POST /requests/{requestId}/select`;
   - returns the selection draft, fees, totals, and request ID.
2. `ConfirmFulfillmentUseCase`
   - accepts request ID and typed `FulfillmentMethod`;
   - sends `POST /requests/{requestId}/confirm`;
   - returns master-order/payment state.

Presentation changes:

- After selection succeeds, show a delivery/pickup confirmation step.
- Preserve the selected pharmacy groups, items, delivery fee, and total on that step.
- Disable duplicate submission while either request is in flight.
- Navigate only after fulfillment confirmation succeeds.
- Cash routes to order completion/details.
- Card routes to payment with the returned master-order ID.
- Do not clear the pending request ID until selection has succeeded; ensure retrying fulfillment does not submit selection twice. Persist minimal selection/master-order handoff state if the flow must survive app termination.

Localization/accessibility:

- Add English and Arabic strings for delivery, pickup, confirmation, validation, and retry.
- Use semantic leading/trailing layout and accessibility selection traits.

Tests:

- Verify exact request bodies for both fulfillment values.
- Verify selection success followed by fulfillment failure remains retryable without reselection.
- Verify cash/card routing.
- Verify duplicate taps produce one request per transition.

### Phase 3: harden Stripe and pending-payment flow

Keep the existing Payment feature architecture, then adjust behavior to the backend state machine:

- Always refresh master order before creating a PaymentIntent.
- Allow payment only for `CARD + PENDING_PAYMENT` before `paymentExpiresAt`.
- Treat `PENDING`, `FAILED`, and `CANCELED` payment statuses as retryable before expiry.
- Treat `PAID` or a promoted order status (`PREPARING` onward) as success.
- Treat `EXPIRED`, `CANCELLED`, or a passed deadline as expired/unavailable.
- Keep PaymentSheet completion as processing until the backend webhook is observed.
- Continue polling when the app becomes active after PaymentSheet redirect/backgrounding.
- Provide a manual refresh when the webhook takes longer than the short automatic polling window.
- Cancel polling tasks when the view disappears.
- Never submit amount/currency from iOS.
- Preserve Stripe return URL handling and validate the publishable-key configuration path.
- Stop creating/presenting payment at the client deadline even if the backend scheduler has not changed the order yet.

Backend follow-up risk: the server currently does not enforce the deadline when creating a PaymentIntent and can promote an expired/cancelled order if a late Stripe success webhook arrives. iOS guards reduce exposure but cannot guarantee this invariant; log it as a backend blocker before production payment release.

Pending-payment resume entry points:

- Show a clear `Pay now`/`Retry payment` action on master-order cards when actionable.
- Keep the action on master-order details.
- Route both through the same `PaymentFactory` and master-order ID.
- After success or expiry, refresh list and detail state rather than mutating local status optimistically.

Tests:

- Cover `PENDING`, `FAILED`, `CANCELED`, `PAID`, `EXPIRED`, order `CANCELLED`, and local deadline-passed states.
- Cover PaymentSheet completed/cancelled/failed outcomes.
- Cover polling success, timeout, cancellation, foreground refresh, and transient request failure.

### Phase 4: align customer master-order list and filters

Networking:

- Extend `OrdersEndpoint.fetchOrders` with `lang` and optional exact `status`.
- Thread filter intent through data source, repository, and use case instead of discarding it.
- Send backend status for filters that map to exactly one value:
  - completed -> `DELIVERED`;
  - cancelled -> `CANCELLED`;
  - a dedicated pending-payment filter -> `PENDING_PAYMENT` if included in product UI.
- For composite `active`, either fetch all pages and filter locally or load each supported active status deliberately. Do not stop after a page merely because that page has no local match.
- Continue applying fulfillment and date filters locally because the backend does not support them.

Presentation:

- Represent `PENDING_PAYMENT` distinctly with payment action and countdown/deadline state.
- Add `READY_FOR_DELIVERY` alongside `READY_FOR_PICKUP`.
- Treat `DELIVERED` as the only completed backend state.
- Keep `CANCELLED` separate.
- Refresh when returning from payment and on pull-to-refresh/app foreground.
- Ensure pagination does not duplicate master orders after filter changes.

Tests:

- Assert exact query parameters, including `status`, `lang`, `page`, and `size`.
- Cover active composite pagination and exact server-filter mapping.
- Cover all status label/color/active-history classifications.

### Phase 5: align customer master-order details

Data/domain:

- Retain master-level `id`, `requestId`, payment, fulfillment, fees, total, deadline, paid timestamp, and aggregate status.
- Preserve each pharmacy group with `subOrderId`, pharmacy metadata, coordinates, and item lines.
- Do not flatten away pharmacy ownership in domain mapping.
- Use nullable fulfillment before confirmation defensively.
- Avoid inventing an order creation date. Until backend adds one, label inferred timestamps honestly or omit the date.

UI:

- Show aggregate status and fulfillment method.
- Show each pharmacy and its items in separate sections/cards.
- Show item subtotal, delivery fee, and master total.
- Show card payment state/deadline when applicable.
- Show pay/retry only when action is valid.
- Show cash without a fake online payment status.
- Retain reorder as an independent existing action.
- Refresh details after payment and when returning from background.

Tests:

- Cover multi-pharmacy grouping and totals.
- Cover cash null payment fields.
- Cover pending-payment, paid, expired, delivery, and pickup presentations.

### Phase 6: replace pharmacy request fallback with real order APIs

Create/complete the Pharmacy Orders clean-architecture chain for:

- `GET /orders/pharmacy/{pharmacyId}` with `lang`, optional `status`, page, and size;
- `GET /orders/{subOrderId}` with `lang`;
- `PATCH /pharmacists/orders/{subOrderId}/ready`;
- `PATCH /pharmacists/orders/{subOrderId}/out-for-delivery`;
- `PATCH /pharmacists/orders/{subOrderId}/delivered`.

Remove from the Pharmacy Orders feature:

- `/pharmacies/requests` as its primary endpoint;
- the decode-then-retry fallback between request and order DTOs;
- `PharmacySubmittedOffersStore` as a way to derive post-order status;
- hardcoded cash payment presentation;
- obsolete order statuses.

Because the backend default query currently returns `PENDING_PAYMENT`, either request exact actionable statuses or exclude `PENDING_PAYMENT` from the visible actionable list. It may be shown only as a disabled informational state if product explicitly requires it; it must never expose preparation actions.

Do not change the separate Request Details feature's request-assignment and offer submission flow.

Tests:

- Assert endpoint paths, methods, query parameters, and authentication.
- Decode the latest `OrderResponse` including nullable fields and nested product.
- Verify server-side status filter values.

### Phase 7: pharmacy order list, details, and transitions

List:

- Filters should represent actionable backend states rather than assignment states.
- Suggested groups:
  - all active: `PREPARING`, ready states, and `OUT_FOR_DELIVERY`;
  - preparing;
  - ready;
  - out for delivery;
  - delivered.
- Load exact status from the backend where possible; combine pages/states correctly for composite groups.
- Display customer, total, payment method, fulfillment-aware status, and date.
- Refresh after a status mutation.

Details:

- Use a dedicated pharmacy order-details model/view rather than the offer/request-details state.
- Show customer contact/address/notes/prescription, localized product lines, subtotal/total, payment method, and fulfillment method inferred from master-order behavior exposed by the order status.
- Only expose valid actions:
  - `PREPARING` -> Mark ready;
  - `READY_FOR_DELIVERY` -> Out for delivery;
  - `OUT_FOR_DELIVERY` -> Delivered;
  - `READY_FOR_PICKUP` -> Collected (calls delivered endpoint);
  - `DELIVERED`/`CANCELLED`/payment-pending -> no mutation.
- Disable duplicate actions and show localized backend errors.
- Refresh detail after every mutation and synchronize the list when navigating back.

Contract limitation:

- Current `OrderResponse` does not include `fulfillmentMethod`. Ready status distinguishes pickup/delivery only after the ready transition. Before that, a pharmacy cannot derive which ready status the backend will choose. The UI should use a generic `Mark ready` action while `PREPARING`, which matches backend behavior.

Tests:

- Cover allowed action per status.
- Cover idempotent already-transitioned responses and invalid transitions.
- Cover delivery and pickup terminal flows.
- Cover unauthorized/wrong-pharmacy and not-found errors.

### Phase 8: integration and regression coverage

Integration scenarios to verify across both apps:

1. Single pharmacy + cash + delivery.
2. Multiple pharmacies + cash + pickup.
3. Single pharmacy + card + payment success.
4. Multiple pharmacies + card + webhook delay.
5. Card PaymentSheet cancellation then resume from order details.
6. Card failure then retry before deadline.
7. Card deadline passes while app is backgrounded.
8. Master order stays in an intermediate aggregate status until every pharmacy sub-order catches up.
9. Arabic responses and RTL UI for patient and pharmacy.
10. Pagination and exact status filtering.

Verification per repository policy:

- Add focused unit/contract tests for every new mapper, endpoint, use case, and view-model transition.
- Run `git diff --check` and inspect the full diff.
- Do not push until the user completes manual Xcode testing and explicitly approves the push.

## Proposed commit structure

Keep commits coherent and inside the requested features. A practical sequence is:

1. `feat(payment): align selection and fulfillment contracts`
2. `feat(payment): harden pending card payment flow`
3. `feat(orders): align customer master order history`
4. `feat(pharmacy-orders): consume post-payment order lifecycle`
5. `test(payment): cover request to delivered order scenarios`

If the user requires fewer commits, combine implementation by app boundary without mixing unrelated changes.

## Acceptance criteria

The work is ready for manual testing when all statements are true:

- A customer explicitly selects delivery or pickup after product selection.
- Cash confirmation reaches `PREPARING` without showing Stripe.
- Card confirmation reaches `PENDING_PAYMENT`, opens PaymentSheet, and waits for webhook-confirmed payment.
- Pending card payment is resumable before expiry and disabled after expiry.
- Customer order list and details decode every current master-order status and response field needed by UI.
- Customer filter requests use the backend `status` query when the filter is exact.
- Multi-pharmacy master orders preserve pharmacy grouping in details.
- Pharmacy post-order screens load `/orders/pharmacy/{id}`, not request assignments.
- Pharmacy users can complete valid delivery and pickup transitions through the three patch endpoints.
- Pharmacy users cannot act on unpaid card orders.
- Both apps refresh from backend after payment/status mutations.
- English and Arabic strings and layouts cover every new state/action.
- Automated contract/state tests pass, `git diff --check` is clean, and the user approves the manual Xcode build before push.

## Decisions required before implementation

The following product decisions do not block contract work, but should be confirmed before final UI behavior:

1. Where should fulfillment selection appear: a new screen after order review, or an expanded section in order review?
2. Should `PENDING_PAYMENT` be a dedicated customer filter chip or appear only inside Active?
3. Should a PaymentSheet cancellation keep the user on the payment screen or return directly to order details with a `Pay now` action?
4. For a multi-pharmacy delivery, should the customer see only the aggregate master status or also each pharmacy's individual status? The current master-order response exposes pharmacy groups but not each sub-order status.
5. Should pharmacy delivered orders remain in the main Orders tab or move to the existing Completed Orders feature? Avoid implementing two competing histories.

Recommended defaults are: fulfillment on a dedicated confirmation step, pending payment inside Active with a prominent pay action, cancellation returns to order details, patient shows aggregate status, and delivered pharmacy orders use one canonical completed-order destination.
