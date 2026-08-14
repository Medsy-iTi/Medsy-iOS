<!--
  payment-master-order-remaining-work.md
  Medsy

  Created by Ahmed Elkady on 13/08/2026.
-->

# Remaining Payment and Master-Order Work

## Scope

This file tracks only the patient `Payment` and patient `Orders` / master-order work owned on `feature/payment`.

Do not expand this into pharmacy orders, catalog, chatbot, profile, cart, complete-request UI, or unrelated theme work unless a backend contract regression directly blocks payment or master-order behavior.

## Already handled on the branch

- Payment flow is connected to backend-created Stripe PaymentIntents using the returned client secret.
- Stripe is now opened directly on the card-entry screen instead of showing Link, Cash App Pay, Amazon Pay, and Bank options.
- PaymentSheet completion is treated as processing until backend payment status is refreshed.
- Payment polling/manual status refresh is available for pending payment.
- Pending-payment resume is connected from patient order details.
- Patient master-order list/detail decoding handles the latest backend status/payment fields.
- Orders list supports payment action state for `PENDING_PAYMENT`.
- Local date-time decoding was adjusted for backend timestamps.
- Complete Request uses the existing cash/card payment enum boundary and does not send fulfillment method.
- Lifecycle and implementation-plan docs are available in `docs/`.

## Remaining iOS work

1. Add the payment entry point on the patient master-order card if product wants payment retry directly from the list, not only from details.
2. Refresh the order list automatically after returning from a successful or expired payment flow.
3. Make pending-payment countdown/deadline display consistent in both order list and order details.
4. Confirm all actionable payment states with manual testing:
   - `PENDING_PAYMENT` + `PENDING` before deadline: allow pay/retry.
   - `PENDING_PAYMENT` + `FAILED` before deadline: allow retry.
   - `PENDING_PAYMENT` + `CANCELED` before deadline: allow retry.
   - `PAID` or `PREPARING` onward: show success/order progress.
   - `EXPIRED`, `CANCELLED`, or local deadline passed: disable payment.
5. Confirm Stripe 3-D Secure return behavior on the real app URL scheme.
6. Confirm Arabic and English payment screen copy after manual testing on device/simulator.
7. Decide whether `UserDefaults` payment/order handoff state is acceptable for this release or should be replaced by scoped persistence.
8. Review whether active-order composite filtering can miss results across paginated backend pages, then either fetch exact statuses separately or document the limitation.
9. Add optional exact backend status query filtering only for filters that map to one backend status.
10. Keep `DELIVERED` as the completed master-order state; do not reintroduce unsupported `COMPLETED` into current order logic.

## Backend questions to confirm

1. Confirm deployed backend `STRIPE_CURRENCY` is `egp` if the Stripe sheet should show EGP. If it shows `US$`, that is likely backend/environment currency, not the iOS label.
2. Confirm Stripe Dashboard -> Workbench -> Webhooks shows `payment_intent.succeeded` delivered to the backend webhook endpoint with HTTP 200.
3. Confirm backend rejects or safely ignores late payment success for an expired/cancelled master order.
4. Confirm `POST /api/v1/payments/create-intent` only needs `orderId` and always derives amount/currency server-side.
5. Confirm whether backend wants to keep Stripe automatic payment methods enabled. iOS now presents card entry directly, but backend may still create intents that allow more methods.

## Manual test checklist

1. Create request with cash, select offer, confirm delivery, verify master order moves to preparing.
2. Create request with cash, select offer, confirm pickup, verify delivery fee and fulfillment display.
3. Create request with card, select offer, confirm delivery, verify order becomes pending payment.
4. Open card payment, use `4242 4242 4242 4242`, future expiry, any CVC, and confirm the UI leaves the processing state after webhook/status refresh.
5. Cancel Stripe card entry and verify retry remains available before expiry.
6. Let payment expire and verify retry is blocked.
7. Open order details for pending, preparing, ready, out-for-delivery, delivered, cancelled, and expired orders.
8. Switch Arabic/English and confirm order/payment text, amounts, and dates are readable.

## Commit status

Latest local commits created for this implementation:

- `feat: implement payment flow updates`
- `feat: update patient master orders`

No automated checks or Xcode build were run, per manual-test instruction.
