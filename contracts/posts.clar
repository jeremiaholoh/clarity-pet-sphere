;; Posts Contract

;; Constants
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-UNAUTHORIZED (err u403))
(define-constant ERR-ALREADY-LIKED (err u401))

(define-map posts uint 
  {
    owner: principal,
    content: (string-utf8 1024),
    image-url: (optional (string-utf8 256)),
    likes: uint,
    created-at: uint,
    active: bool
  }
)

(define-data-var post-counter uint u0)

(define-map post-likes {post-id: uint, user: principal} bool)

(define-public (create-post (content (string-utf8 1024)) (image-url (optional (string-utf8 256))))
  (let 
    (
      (post-id (+ (var-get post-counter) u1))
      (post {
        owner: tx-sender,
        content: content,
        image-url: image-url,
        likes: u0,
        created-at: block-height,
        active: true
      })
    )
    (var-set post-counter post-id)
    (ok (map-set posts post-id post))
  )
)

(define-public (delete-post (post-id uint))
  (let ((post (unwrap! (map-get? posts post-id) ERR-NOT-FOUND)))
    (asserts! (is-eq tx-sender (get owner post)) ERR-UNAUTHORIZED)
    (ok (map-set posts post-id 
      (merge post {active: false})
    ))
  )
)

(define-public (like-post (post-id uint))
  (let ((post (unwrap! (map-get? posts post-id) ERR-NOT-FOUND)))
    (asserts! (get active post) ERR-NOT-FOUND)
    (if (map-get? post-likes {post-id: post-id, user: tx-sender})
      ERR-ALREADY-LIKED
      (begin
        (map-set post-likes {post-id: post-id, user: tx-sender} true)
        (ok (map-set posts post-id 
          (merge post {likes: (+ (get likes post) u1)}))
        )
      )
    )
  )
)

(define-read-only (has-liked (post-id uint) (user principal))
  (default-to false (map-get? post-likes {post-id: post-id, user: user}))
)
