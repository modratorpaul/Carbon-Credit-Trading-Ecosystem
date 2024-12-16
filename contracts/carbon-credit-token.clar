;; Carbon Credit Token Contract

(define-fungible-token carbon-credit-token)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ft-mint? carbon-credit-token amount recipient)))

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (ft-transfer? carbon-credit-token amount sender recipient)))

(define-public (burn (amount uint) (sender principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (ft-burn? carbon-credit-token amount sender)))

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance carbon-credit-token account)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply carbon-credit-token)))

