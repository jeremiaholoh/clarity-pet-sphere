;; Posts Contract
(define-map posts uint 
  {
    owner: principal,
    content: (string-utf8 1024),
    image-url: (optional (string-utf8 256)),
    likes: uint,
    created-at: uint
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
        created-at: block-height
      })
    )
    (var-set post-counter post-id)
    (ok (map-set posts post-id post))
  )
)

(define-public (like-post (post-id uint))
  (let ((post (unwrap! (map-get? posts post-id) (err u404))))
    (if (map-get? post-likes {post-id: post-id, user: tx-sender})
      (err u403)
      (ok (map-set posts post-id 
        (merge post {likes: (+ (get likes post) u1)})))
    )
  )
)
