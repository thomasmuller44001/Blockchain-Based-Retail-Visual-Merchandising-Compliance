;; Store Verification Contract
;; Validates legitimate retail locations

(define-data-var admin principal tx-sender)

;; Map to store verified retail locations
(define-map verified-stores
  { store-id: (string-ascii 64) }
  {
    owner: principal,
    name: (string-ascii 100),
    location: (string-ascii 100),
    verified: bool,
    verification-date: uint
  }
)

;; Public function to register a new store
(define-public (register-store (store-id (string-ascii 64)) (name (string-ascii 100)) (location (string-ascii 100)))
  (let ((caller tx-sender))
    (if (map-insert verified-stores
                    { store-id: store-id }
                    {
                      owner: caller,
                      name: name,
                      location: location,
                      verified: false,
                      verification-date: u0
                    })
        (ok true)
        (err u1))))

;; Admin function to verify a store
(define-public (verify-store (store-id (string-ascii 64)))
  (let ((caller tx-sender)
        (admin-principal (var-get admin)))
    (if (is-eq caller admin-principal)
        (match (map-get? verified-stores { store-id: store-id })
          store-data (begin
            (map-set verified-stores
                     { store-id: store-id }
                     (merge store-data {
                       verified: true,
                       verification-date: block-height
                     }))
            (ok true))
          (err u3))
        (err u2))))

;; Read-only function to check if a store is verified
(define-read-only (is-store-verified (store-id (string-ascii 64)))
  (match (map-get? verified-stores { store-id: store-id })
    store-data (get verified store-data)
    false))

;; Read-only function to get store details
(define-read-only (get-store-details (store-id (string-ascii 64)))
  (map-get? verified-stores { store-id: store-id }))

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (let ((caller tx-sender)
        (current-admin (var-get admin)))
    (if (is-eq caller current-admin)
        (begin
          (var-set admin new-admin)
          (ok true))
        (err u4))))
