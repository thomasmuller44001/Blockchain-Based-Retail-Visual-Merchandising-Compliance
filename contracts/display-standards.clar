;; Display Standards Contract
;; Defines required presentation guidelines

(define-data-var admin principal tx-sender)

;; Map to store display standards by category
(define-map display-standards
  { standard-id: (string-ascii 64) }
  {
    category: (string-ascii 64),
    description: (string-utf8 500),
    required-elements: (list 10 (string-ascii 100)),
    created-at: uint,
    updated-at: uint
  }
)

;; Public function to add a new display standard (admin only)
(define-public (add-display-standard
                (standard-id (string-ascii 64))
                (category (string-ascii 64))
                (description (string-utf8 500))
                (required-elements (list 10 (string-ascii 100))))
  (let ((caller tx-sender)
        (admin-principal (var-get admin))
        (current-block block-height))
    (if (is-eq caller admin-principal)
        (if (map-insert display-standards
                      { standard-id: standard-id }
                      {
                        category: category,
                        description: description,
                        required-elements: required-elements,
                        created-at: current-block,
                        updated-at: current-block
                      })
            (ok true)
            (err u1))  ;; Standard ID already exists
        (err u2))))    ;; Not authorized

;; Public function to update an existing display standard (admin only)
(define-public (update-display-standard
                (standard-id (string-ascii 64))
                (category (string-ascii 64))
                (description (string-utf8 500))
                (required-elements (list 10 (string-ascii 100))))
  (let ((caller tx-sender)
        (admin-principal (var-get admin))
        (current-block block-height))
    (if (is-eq caller admin-principal)
        (match (map-get? display-standards { standard-id: standard-id })
          standard-data (begin
            (map-set display-standards
                     { standard-id: standard-id }
                     {
                       category: category,
                       description: description,
                       required-elements: required-elements,
                       created-at: (get created-at standard-data),
                       updated-at: current-block
                     })
            (ok true))
          (err u3))  ;; Standard not found
        (err u2))))  ;; Not authorized

;; Read-only function to get display standard details
(define-read-only (get-display-standard (standard-id (string-ascii 64)))
  (map-get? display-standards { standard-id: standard-id }))

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (let ((caller tx-sender)
        (current-admin (var-get admin)))
    (if (is-eq caller current-admin)
        (begin
          (var-set admin new-admin)
          (ok true))
        (err u4))))
