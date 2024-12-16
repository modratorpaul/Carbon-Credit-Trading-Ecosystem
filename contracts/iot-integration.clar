;; IoT Integration Contract

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-invalid-device (err u102))

(define-map iot-devices
  { device-id: (string-ascii 50) }
  {
    owner: principal,
    project-id: uint,
    last-reading: uint,
    last-update: uint
  }
)

(define-map authorized-updaters principal bool)

(define-public (register-device (device-id (string-ascii 50)) (project-id uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set iot-devices
      { device-id: device-id }
      {
        owner: tx-sender,
        project-id: project-id,
        last-reading: u0,
        last-update: block-height
      }))))

(define-public (update-device-reading (device-id (string-ascii 50)) (reading uint))
  (let
    ((device (unwrap! (map-get? iot-devices { device-id: device-id }) err-invalid-device)))
    (asserts! (or (is-eq tx-sender (get owner device)) (default-to false (map-get? authorized-updaters tx-sender))) err-not-authorized)
    (ok (map-set iot-devices
      { device-id: device-id }
      (merge device {
        last-reading: reading,
        last-update: block-height
      })))))

(define-public (add-authorized-updater (updater principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set authorized-updaters updater true))))

(define-public (remove-authorized-updater (updater principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-delete authorized-updaters updater))))

(define-read-only (get-device-info (device-id (string-ascii 50)))
  (ok (unwrap! (map-get? iot-devices { device-id: device-id }) err-invalid-device)))

