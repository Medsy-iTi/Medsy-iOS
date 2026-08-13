<!--
  request-to-order-lifecycle.md
  Medsy

  Created by Ahmed Elkady on 13/08/2026.
-->

# Medsy Request-to-Order Lifecycle

## Purpose and source snapshot

This document describes the complete medicine-request lifecycle across the Medsy patient and pharmacy apps, from request creation through a delivered/collected master order. It is the contract baseline for the `feature/payment` work.

The analysis is based on:

- Backend repository: `DawaNow`
- Backend branch: `master`
- Backend commit: `ebee7cc` (`Merge pull request #45 ... feature/request-lifecycle`)
- iOS repository branch: `feature/payment`
- iOS commit at analysis time: `7794ada`
- Analysis date: 2026-08-13

The backend implementation is the source of truth for the API contracts in this document. Several Swagger descriptions still use older wording; the controller, service, entity, mapper, and repository implementations were used to resolve those differences.

## Core concepts

### Medicine request

A `MedicineRequest` is the customer's search for medicine availability. It owns the requested products, quantities, delivery coordinates/address, notes, prescription, and the payment method chosen before submission.

Its status is independent from the later order lifecycle:

- `SEARCHING`: pharmacies can respond and the customer can choose products.
- `COMPLETED`: the customer confirmed a selection. This means selection is complete, not that delivery is complete.
- `CANCELLED`: the request was cancelled.
- `EXPIRED`: no selection was confirmed before the search timeout.

### Master order

A `MasterOrder` is created when the customer confirms selected request-item/product pairs. It represents the customer's single checkout and payment lifecycle. It owns:

- one original medicine request;
- one or more pharmacy sub-orders;
- payment method and payment state;
- fulfillment method;
- combined item total plus delivery fee;
- aggregate order status;
- card payment expiry and paid timestamp.

### Pharmacy sub-order

An `Order` is the portion of a master order fulfilled by one pharmacy. The backend optimizer selects the smallest valid set of pharmacies, groups selected products by pharmacy, and creates one sub-order per selected pharmacy.

Pharmacy users operate on sub-order IDs. Patient users primarily browse master-order IDs.

## End-to-end sequence

### 1. Patient creates a medicine request

The patient app submits the current cart as multipart form data.

```http
POST /api/v1/requests?lang=en
Authorization: Bearer <customer token>
Content-Type: multipart/form-data

request: application/json
{
  "deliveryLatitude": 30.0444,
  "deliveryLongitude": 31.2357,
  "deliveryAddress": "...",
  "notes": "...",
  "paymentMethod": "CASH" | "CARD"
}

prescription: <optional JPEG, PNG, or PDF>
```

Backend behavior:

1. Requires a non-empty cart.
2. Copies cart items into request items.
3. Sets request status to `SEARCHING`.
4. Sets request expiry to the configured search timeout, currently defaulting to 15 minutes.
5. Assigns the request to nearby pharmacies.
6. Clears the cart.

Important: fulfillment is not fixed at this point. The request body still requires delivery coordinates because the current backend request and generated sub-order entities require them even if the customer later chooses pickup.

### 2. Pharmacy receives the request and submits an offer

The pharmacy app obtains request assignments using:

```http
GET /api/v1/pharmacies/requests?lang=en&status=PENDING&page=0&size=20
GET /api/v1/pharmacies/requests/{requestId}?lang=en
```

Assignment states are `PENDING`, `OFFER_CREATED`, and `EXPIRED`.

The pharmacy responds with products for the assigned request items:

```http
POST /api/v1/offers/requests/{requestId}?lang=en
{
  "items": [
    {
      "requestItemId": 101,
      "productId": 5001
    }
  ]
}
```

The backend marks different products as alternatives, updates request-item availability, and emits result updates through the request SSE stream.

### 3. Patient reads the live result and selects products

The patient can read a snapshot or subscribe to updates:

```http
GET /api/v1/requests/{requestId}/result?lang=en
GET /api/v1/requests/{requestId}/stream?lang=en
```

The result contains:

- `medicineRequestResultItemList`;
- each `requestItemId`;
- selected/best `productId`, unit price, availability, and alternative flag;
- localized `product` and alternatives;
- calculated item total;
- the request payment method.

The request cannot be selected after its status becomes `EXPIRED` or `COMPLETED`.

### 4. Patient confirms item selection

```http
POST /api/v1/requests/{requestId}/select
{
  "selectedItems": [
    {
      "requestItemId": 101,
      "productId": 5001
    }
  ]
}
```

Validation and processing:

1. The request must belong to the current customer and be `SEARCHING`.
2. A master order must not already exist for the request.
3. Request-item IDs must be unique.
4. Every chosen product must have actually been offered for its request item.
5. Rejected and expired offers cannot be selected.
6. The optimizer chooses a valid set using the minimum number of pharmacies.
7. One `PENDING` sub-order is created per selected pharmacy.
8. Delivery fee is calculated from the number of pharmacies.
9. Master total is the sum of sub-order totals plus the delivery fee.
10. Selected offers become `ACCEPTED` or `PARTIALLY_ACCEPTED`; unselected pending offers become `REJECTED`.
11. The medicine request becomes `COMPLETED`, pending assignments expire, and its SSE stream closes.

Current response:

```json
{
  "success": true,
  "message": "Selection confirmed and orders created",
  "data": {
    "requestId": 42,
    "offers": [
      {
        "offerId": 901,
        "pharmacyId": 7,
        "pharmacyName": "Pharmacy name",
        "latitude": 30.0,
        "longitude": 31.0,
        "items": []
      }
    ],
    "deliveryFees": 20.0,
    "totalPrice": 250.0
  }
}
```

Contract note: `OrderDraftResponse.offerId` is currently populated with the created sub-order ID, not the accepted offer ID. The iOS layer should model this as `subOrderId` internally while decoding the current `offerId` JSON key.

### 5. Patient confirms fulfillment method

Selection and fulfillment confirmation are separate operations. The app must present `DELIVERY` and `PICKUP` after selection and send the explicit choice:

```http
POST /api/v1/requests/{requestId}/confirm
{
  "fulfillmentMethod": "DELIVERY" | "PICKUP"
}
```

Response:

```json
{
  "success": true,
  "message": "Order confirmed with fulfillment method",
  "data": {
    "masterOrderId": 3001,
    "orderStatus": "PREPARING" | "PENDING_PAYMENT",
    "paymentMethod": "CASH" | "CARD",
    "paymentStatus": null | "PENDING"
  }
}
```

#### Cash

- Master and all sub-orders move from `PENDING` to `PREPARING`.
- `paymentStatus`, `paymentIntentId`, and `paidAt` are null because cash is not tracked as an online payment.
- Each selected pharmacy is notified that its sub-order is ready to prepare.

#### Card

- Master and all sub-orders move from `PENDING` to `PENDING_PAYMENT`.
- `paymentStatus` becomes `PENDING`.
- `paymentExpiresAt` becomes backend-now plus 15 minutes.
- Pharmacies are not notified yet and do not receive an actionable order in their default order feed.

### 6. Card payment

The patient creates or reuses a Stripe PaymentIntent for the master order:

```http
POST /api/v1/payments/create-intent
{
  "orderId": 3001
}
```

The `orderId` field is a master-order ID despite its generic name. The backend derives the amount from `masterOrder.totalPrice`; the client must never send or trust a client-calculated charge amount.

Response:

```json
{
  "success": true,
  "message": "Payment intent created",
  "data": {
    "paymentIntentId": "pi_...",
    "clientSecret": "pi_..._secret_..."
  }
}
```

The patient presents Stripe PaymentSheet using the returned client secret. Payment completion in the app is not authoritative. The Stripe webhook is authoritative:

- `payment_intent.succeeded`: payment becomes `PAID`, `paidAt` is set, master and sub-orders become `PREPARING`, and pharmacies are notified.
- `payment_intent.payment_failed`: payment becomes `FAILED`; order stays `PENDING_PAYMENT`, allowing retry before expiry.
- `payment_intent.canceled`: payment becomes `CANCELED`; order stays `PENDING_PAYMENT`, allowing a new/reused attempt before expiry.
- Duplicate webhook events are ignored using stored Stripe event IDs.

The patient should poll `GET /api/v1/masterorders/{masterOrderId}` after PaymentSheet completion until the webhook changes the backend state. A local PaymentSheet success must never directly mark the order paid.

### 7. Pending payment expiry and resume

Card payment is recoverable from the master-order list and details while all are true:

- `paymentMethod == CARD`;
- `orderStatus == PENDING_PAYMENT`;
- `paymentStatus` is `PENDING`, `FAILED`, or `CANCELED`;
- `paymentExpiresAt` is in the future.

The backend expiration scheduler queries expired `PENDING_PAYMENT` master orders and changes master plus sub-orders to `CANCELLED`, with `paymentStatus = EXPIRED`.

Important timing detail: the expiry scheduler currently runs with a 15-minute fixed delay. The server may continue returning `PENDING_PAYMENT` briefly after `paymentExpiresAt`. The patient app must treat the timestamp as expired immediately in the UI and refresh until the backend converges; it must not offer payment after the timestamp.

### 8. Pharmacy processes sub-orders

The pharmacy app's post-selection order feed is separate from the request-assignment feed:

```http
GET /api/v1/orders/pharmacy/{pharmacyId}?lang=en&page=0&size=20
GET /api/v1/orders/pharmacy/{pharmacyId}?lang=en&status=PREPARING&page=0&size=20
GET /api/v1/orders/{subOrderId}?lang=en
```

Without a status parameter, the backend hides only `PENDING` and `CANCELLED`. It does not hide `PENDING_PAYMENT`, so unpaid card sub-orders can appear in the default response even though pharmacies have not been notified and must not prepare them. The pharmacy iOS app must hide or clearly disable those entries and should prefer explicit actionable status queries.

Each sub-order response includes customer, pharmacy, pharmacist, notes, address, phone, prescription, totals, coordinates, current status, master-order payment method, and localized product items.

#### Delivery lifecycle

1. `PREPARING`
2. Pharmacy calls `PATCH /api/v1/pharmacists/orders/{subOrderId}/ready`.
3. Sub-order becomes `READY_FOR_DELIVERY`.
4. When all sub-orders are ready, master order becomes `READY_FOR_DELIVERY`.
5. Pharmacy calls `PATCH /api/v1/pharmacists/orders/{subOrderId}/out-for-delivery`.
6. Sub-order becomes `OUT_FOR_DELIVERY`.
7. When all sub-orders are out, master order becomes `OUT_FOR_DELIVERY`.
8. Pharmacy calls `PATCH /api/v1/pharmacists/orders/{subOrderId}/delivered`.
9. Sub-order becomes `DELIVERED`.
10. When all sub-orders are delivered, master order becomes `DELIVERED`.

#### Pickup lifecycle

1. `PREPARING`
2. Pharmacy calls `PATCH /api/v1/pharmacists/orders/{subOrderId}/ready`.
3. Sub-order becomes `READY_FOR_PICKUP`.
4. When all sub-orders are ready, master order becomes `READY_FOR_PICKUP`.
5. After collection, pharmacy calls `PATCH /api/v1/pharmacists/orders/{subOrderId}/delivered`.
6. Sub-order becomes `DELIVERED`.
7. When all sub-orders are collected, master order becomes `DELIVERED`.

The backend uses `DELIVERED` as the terminal status for both delivery and pickup. There is no `COMPLETED` order status in the current backend enum.

## Master-order APIs

### Customer list and server status filter

```http
GET /api/v1/masterorders?lang=en&status=PREPARING&page=0&size=20
```

- Customer-only.
- Sorted newest master-order ID first.
- `status` is optional and must be one exact `OrderStatus` value:
  `PENDING`, `PENDING_PAYMENT`, `PREPARING`, `READY_FOR_PICKUP`,
  `READY_FOR_DELIVERY`, `OUT_FOR_DELIVERY`, `DELIVERED`, or `CANCELLED`.
- The backend does not support a list of statuses, fulfillment filters, or date-range filters in this endpoint.
- Pagination keys are `content`, `pageNumber`, `pageSize`, `totalElements`, `totalPages`, and `last`.

### Customer detail

```http
GET /api/v1/masterorders/{masterOrderId}?lang=en
```

`MasterOrderResponse` fields:

| Field | Meaning |
| --- | --- |
| `id` | Master-order ID used by payment and patient details |
| `requestId` | Original medicine-request ID |
| `orderResponses` | One draft per selected pharmacy; current `offerId` value is the sub-order ID |
| `paymentMethod` | `CASH` or `CARD` |
| `paymentStatus` | Null for cash; otherwise `UNPAID`, `PENDING`, `PAID`, `FAILED`, `CANCELED`, or `EXPIRED` |
| `fulfillmentMethod` | Null before confirmation, then `DELIVERY` or `PICKUP` |
| `deliveryFee` | Master-level fee calculated during selection |
| `totalPrice` | All item totals plus delivery fee |
| `orderStatus` | Aggregate master-order status |
| `paymentExpiresAt` | Card deadline; null for cash |
| `paidAt` | Stripe success timestamp; null until paid and always null for cash |

## State machines

### Medicine request

```text
SEARCHING ──select──> COMPLETED
    │
    └──timeout──> EXPIRED
```

### Master order: cash

```text
PENDING ──confirm fulfillment──> PREPARING
  ├─ delivery ─> READY_FOR_DELIVERY ─> OUT_FOR_DELIVERY ─> DELIVERED
  └─ pickup   ─> READY_FOR_PICKUP ───────────────────────> DELIVERED
```

### Master order: card

```text
PENDING ──confirm fulfillment──> PENDING_PAYMENT
                                      ├─ Stripe webhook success ─> PREPARING ─> fulfillment lifecycle
                                      └─ payment deadline ───────> CANCELLED
```

`FAILED` and `CANCELED` are payment statuses while the order remains `PENDING_PAYMENT`; they are retryable only before `paymentExpiresAt`.

## Required app ownership

### Patient app

- Create the medicine request with `CASH` or `CARD`.
- Read request results and choose a product for every selected request item.
- Confirm selection.
- Let the customer choose `DELIVERY` or `PICKUP`, then confirm fulfillment.
- Route cash directly to the created order.
- Route card to Stripe PaymentSheet.
- Poll the master order for webhook-confirmed payment state.
- Show/resume pending payments from master-order list and detail.
- Display master-order aggregate status, payment state, fulfillment method, totals, pharmacy groups, and localized items.
- Send the exact server status filter when the UI chooses one exact status; apply composite filters carefully when the API cannot express them.

### Pharmacy app

- Use request-assignment endpoints only for finding requests and submitting offers.
- Use pharmacy sub-order endpoints for paid/cash-confirmed orders.
- Show only orders relevant to the chosen status/filter.
- Display the sub-order's true payment method instead of assuming cash.
- Fetch sub-order details from `/orders/{subOrderId}`.
- Expose only valid actions for the current status and fulfillment method.
- Call ready, out-for-delivery, and delivered endpoints, then refresh the order/list.
- Never prepare a card order before the backend promotes it to `PREPARING`.

## Backend contract risks to keep visible

These are observed backend behaviors, not requests to change unrelated backend features:

1. `FulfillmentRequest.fulfillmentMethod` has no `@NotNull`; the iOS app must never send null.
2. Fulfillment confirmation does not explicitly verify customer ownership in the service method and does not reject repeated confirmation except through the payment-expiry check. The app must treat it as a one-time transition.
3. `MasterOrderController` allows only customer/admin roles even though its Swagger detail text mentions pharmacy administrators.
4. `OrderController.getOrderById` authorizes only pharmacist/admin roles even though service code contains customer-owner handling. Patient details must use `/masterorders/{id}`.
5. `OrderDraftResponse.offerId` currently carries a sub-order ID.
6. Master-order responses have no explicit creation timestamp; the current iOS fallback infers a date from `paidAt` or `paymentExpiresAt`, which is not reliable for cash orders.
7. The pharmacy default order query hides `PENDING` and `CANCELLED`, but not explicitly `PENDING_PAYMENT`; the product flow should not depend only on this implicit filtering.
8. The order expiration scheduler interval can make server status lag behind `paymentExpiresAt`.
9. Failed/canceled Stripe events change `paymentStatus` but do not extend `paymentExpiresAt`.
10. PaymentIntent creation validates card ownership/method/cancellation but does not explicitly require `PENDING_PAYMENT` or reject a passed `paymentExpiresAt` before the scheduler runs.
11. Stripe success handling does not reject an already expired/cancelled order; a late success event can currently promote it back to `PREPARING`. The iOS app must stop initiating payment at the deadline, but this race ultimately needs a backend invariant.
12. The backend terminal order state is `DELIVERED`; `COMPLETED`, `CONFIRMED`, `ACCEPTED`, and `EXPIRED` are not current `OrderStatus` values.

These risks should be covered through defensive iOS mapping and tests. Any backend change that alters them requires refreshing this document before implementation is merged.
