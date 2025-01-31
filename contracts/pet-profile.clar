;; Pet Profile Contract
(define-map profiles
  { owner: principal }
  {
    pet-name: (string-utf8 64),
    pet-type: (string-utf8 32),
    description: (string-utf8 256),
    created-at: uint
  }
)

(define-public (create-profile (pet-name (string-utf8 64)) (pet-type (string-utf8 32)) (description (string-utf8 256)))
  (let ((profile {owner: tx-sender, pet-name: pet-name, pet-type: pet-type, description: description, created-at: block-height}))
    (ok (map-set profiles {owner: tx-sender} profile))
  )
)

(define-read-only (get-profile (owner principal))
  (ok (map-get? profiles {owner: owner}))
)

(define-public (update-profile (pet-name (string-utf8 64)) (description (string-utf8 256)))
  (let ((existing-profile (unwrap! (get-profile tx-sender) (err u404))))
    (ok (map-set profiles 
      {owner: tx-sender}
      (merge existing-profile {pet-name: pet-name, description: description})
    ))
  )
)
