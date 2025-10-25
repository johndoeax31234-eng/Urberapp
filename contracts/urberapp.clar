;; urber-app
;; Clarity contract for a decentralized ride-sharing platform

(define-data-var ride-counter uint u0)

(define-map rides {id: uint}
  {rider: principal,
   destination: (string-ascii 50),
   driver: (optional principal),
   status: (string-ascii 10)})

;; Request a ride
(define-public (request-ride (destination (string-ascii 50)))
  (begin
    (asserts! (> (len destination) u0) (err u1))
    (let
      (
        (id (var-get ride-counter))
      )
      (map-set rides {id: id}
        {rider: tx-sender,
         destination: destination,
         driver: none,
         status: "open"})
      (var-set ride-counter (+ id u1))
      (ok id)
    )
  )
)

;; Accept a ride as a driver
(define-public (accept-ride (id uint))
  (match (map-get? rides {id: id})
    ride
    (if (is-eq (get status ride) "open")
      (begin
        (map-set rides {id: id}
          {rider: (get rider ride),
           destination: (get destination ride),
           driver: (some tx-sender),
           status: "accepted"})
        (ok "Ride accepted")
      )
      (err u2)) ;; not open
    (err u3)) ;; ride not found
)

;; Complete a ride
(define-public (complete-ride (id uint))
  (match (map-get? rides {id: id})
    ride
    (if (and (is-eq (get status ride) "accepted") (is-eq tx-sender (get rider ride)))
      (begin
        (map-set rides {id: id}
          {rider: (get rider ride),
           destination: (get destination ride),
           driver: (get driver ride),
           status: "completed"})
        (ok "Ride completed")
      )
      (err u4)) ;; not accepted or not rider
    (err u5)) ;; ride not found
)