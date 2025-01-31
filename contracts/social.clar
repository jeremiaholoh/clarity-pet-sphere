;; Social Contract
(define-map follows {follower: principal, following: principal} bool)

(define-public (follow (user principal))
  (ok (map-set follows {follower: tx-sender, following: user} true))
)

(define-public (unfollow (user principal))
  (ok (map-delete follows {follower: tx-sender, following: user}))
)

(define-read-only (is-following (follower principal) (following principal))
  (default-to false (map-get? follows {follower: follower, following: following}))
)
