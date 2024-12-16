;; Carbon Credit Issuance Contract

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-invalid-project (err u102))

(define-map verified-projects
  { project-id: uint }
  {
    name: (string-utf8 100),
    description: (string-utf8 500),
    verified: bool,
    total-credits: uint,
    issued-credits: uint
  }
)

(define-map project-verifiers principal bool)

(define-public (register-project (project-id uint) (name (string-utf8 100)) (description (string-utf8 500)) (total-credits uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set verified-projects
      { project-id: project-id }
      {
        name: name,
        description: description,
        verified: false,
        total-credits: total-credits,
        issued-credits: u0
      }))))

(define-public (verify-project (project-id uint))
  (let
    ((project (unwrap! (map-get? verified-projects { project-id: project-id }) err-invalid-project)))
    (asserts! (default-to false (map-get? project-verifiers tx-sender)) err-not-authorized)
    (ok (map-set verified-projects
      { project-id: project-id }
      (merge project { verified: true })))))

(define-public (issue-credits (project-id uint) (amount uint) (recipient principal))
  (let
    ((project (unwrap! (map-get? verified-projects { project-id: project-id }) err-invalid-project)))
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (get verified project) err-not-authorized)
    (asserts! (<= (+ (get issued-credits project) amount) (get total-credits project)) err-not-authorized)
    (ok (map-set verified-projects
      { project-id: project-id }
      (merge project { issued-credits: (+ (get issued-credits project) amount) })))))

(define-public (add-project-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set project-verifiers verifier true))))

(define-public (remove-project-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-delete project-verifiers verifier))))

(define-read-only (get-project (project-id uint))
  (ok (unwrap! (map-get? verified-projects { project-id: project-id }) err-invalid-project)))

