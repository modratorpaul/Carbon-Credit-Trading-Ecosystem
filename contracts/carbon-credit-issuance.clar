;; Carbon Credit Trading Contract

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-invalid-order (err u102))

(define-map sell-orders
  { order-id: uint }
  {
    seller: principal,
    amount: uint,
    price: uint,
    status: (string-ascii 20)
  }
)

(define-map buy-orders
  { order-id: uint }
  {
    buyer: principal,
    amount: uint,
    price: uint,
    status: (string-ascii 20)
  }
)

(define-data-var last-order-id uint u0)

(define-public (create-sell-order (amount uint) (price uint))
  (let
    ((order-id (+ (var-get last-order-id) u1)))
    (map-set sell-orders
      { order-id: order-id }
      {
        seller: tx-sender,
        amount: amount,
        price: price,
        status: "active"
      })
    (var-set last-order-id order-id)
    (ok order-id)))

(define-public (create-buy-order (amount uint) (price uint))
  (let
    ((order-id (+ (var-get last-order-id) u1)))
    (map-set buy-orders
      { order-id: order-id }
      {
        buyer: tx-sender,
        amount: amount,
        price: price,
        status: "active"
      })
    (var-set last-order-id order-id)
    (ok order-id)))

(define-public (cancel-sell-order (order-id uint))
  (let
    ((order (unwrap! (map-get? sell-orders { order-id: order-id }) err-invalid-order)))
    (asserts! (is-eq tx-sender (get seller
