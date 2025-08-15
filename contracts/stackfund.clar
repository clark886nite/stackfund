;;; StackFund - Crowdfunding Smart Contract

;; Error constants
(define-constant err-campaign-not-found (err u100))
(define-constant err-campaign-expired (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-goal-not-met (err u103))
(define-constant err-already-withdrawn (err u104))
(define-constant err-deadline-not-passed (err u105))
(define-constant err-goal-already-met (err u106))
(define-constant err-invalid-amount (err u107))
(define-constant err-invalid-deadline (err u108))
(define-constant err-transfer-failed (err u109))
(define-constant err-no-contribution (err u110))

;; Data variables
(define-data-var campaign-id uint u0)

;; Data maps
(define-map campaigns
  { id: uint }
  {
    creator: principal,
    goal: uint,
    deadline: uint,
    raised: uint,
    withdrawn: bool
  }
)

(define-map contributions
  { id: uint, contributor: principal }
  { amount: uint }
)

;; Create a new campaign
(define-public (create-campaign (goal uint) (deadline uint))
  (let ((id (var-get campaign-id)))
    (begin
      (asserts! (> goal u0) err-invalid-amount)
      (asserts! (> deadline stacks-block-height) err-invalid-deadline)
      (var-set campaign-id (+ id u1))
      (map-set campaigns { id: id }
        {
          creator: tx-sender,
          goal: goal,
          deadline: deadline,
          raised: u0,
          withdrawn: false
        })
      (ok id)
    )
  )
)

;; Contribute to a campaign
(define-public (contribute (id uint) (amount uint))
  (let (
    (campaign (unwrap! (map-get? campaigns { id: id }) err-campaign-not-found))
    (current-block stacks-block-height)
  )
    (begin
      (asserts! (> amount u0) err-invalid-amount)
      (asserts! (< current-block (get deadline campaign)) err-campaign-expired)
      
      ;; Transfer STX from contributor to contract
      (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
      
      ;; Update contribution record
      (let ((prev-contribution (default-to u0 (get amount (map-get? contributions { id: id, contributor: tx-sender })))))
        (map-set contributions { id: id, contributor: tx-sender } { amount: (+ prev-contribution amount) })
        
        ;; Update campaign raised amount
        (map-set campaigns { id: id }
          (merge campaign { raised: (+ (get raised campaign) amount) }))
        
        (ok true)
      )
    )
  )
)

;; Withdraw funds (only creator, only if goal met)
(define-public (withdraw (id uint))
  (let ((campaign (unwrap! (map-get? campaigns { id: id }) err-campaign-not-found)))
    (begin
      (asserts! (is-eq tx-sender (get creator campaign)) err-unauthorized)
      (asserts! (>= (get raised campaign) (get goal campaign)) err-goal-not-met)
      (asserts! (is-eq (get withdrawn campaign) false) err-already-withdrawn)
      
      ;; Mark as withdrawn
      (map-set campaigns { id: id } (merge campaign { withdrawn: true }))
      
      ;; Transfer funds to creator
      (as-contract (stx-transfer? (get raised campaign) tx-sender (get creator campaign)))
    )
  )
)

;; Refund contribution (only if deadline passed and goal not met)
(define-public (refund (id uint))
  (let (
    (campaign (unwrap! (map-get? campaigns { id: id }) err-campaign-not-found))
    (contrib (unwrap! (map-get? contributions { id: id, contributor: tx-sender }) err-no-contribution))
    (current-block stacks-block-height)
  )
    (begin
      (asserts! (>= current-block (get deadline campaign)) err-deadline-not-passed)
      (asserts! (< (get raised campaign) (get goal campaign)) err-goal-already-met)
      
      ;; Remove contribution record
      (map-delete contributions { id: id, contributor: tx-sender })
      
      ;; Update campaign raised amount (subtract the refunded amount)
      (map-set campaigns { id: id }
        (merge campaign { raised: (- (get raised campaign) (get amount contrib)) }))
      
      ;; Refund STX to contributor (tx-sender is the contributor)
      (as-contract (stx-transfer? (get amount contrib) tx-sender tx-sender))
    )
  )
)

;; Read-only functions
(define-read-only (get-campaign (id uint))
  (map-get? campaigns { id: id })
)

(define-read-only (get-contribution (id uint) (user principal))
  (map-get? contributions { id: id, contributor: user })
)

(define-read-only (get-current-campaign-id)
  (ok (var-get campaign-id))
)

(define-read-only (is-campaign-active (id uint))
  (match (map-get? campaigns { id: id })
    campaign (ok (< stacks-block-height (get deadline campaign)))
    (err u404)
  )
)

(define-read-only (is-goal-met (id uint))
  (match (map-get? campaigns { id: id })
    campaign (ok (>= (get raised campaign) (get goal campaign)))
    (err u404)
  )
)

(define-read-only (get-total-contributions (id uint))
  (match (map-get? campaigns { id: id })
    campaign (ok (get raised campaign))
    err-campaign-not-found
  )
)