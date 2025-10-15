
;; Define the block-height trait
(define-trait block-height-trait 
  (
    (get-block-height () (response uint uint))
  )
)

;; Contract Name: stack-save
;; Description: A simple STX savings vault that lets users 
;; lock up their STX for a chosen period and withdraw later.
;; ----------------------------------------------------
(define-data-var total-deposits uint u0)

(define-map user-savings
  { user: principal }
  { amount: uint, unlock-block: uint })

;; ----------------------------------------------------
;; Function: deposit
;; Params:
;;   - amount: the amount of STX to deposit
;;   - lock-period: how many blocks the STX will be locked
;; ----------------------------------------------------
(define-public (deposit (amount uint) (lock-period uint) (block-height-contract <block-height-trait>))
  (let (
    (sender tx-sender)
    (current-block (unwrap-panic (contract-call? block-height-contract get-block-height)))
    (existing (map-get? user-savings { user: sender }))
   )
    (begin
      (if (is-some existing)
          (err u100) ;; User already has a deposit
          (begin
            (if (<= amount u0)
                (err u101) ;; Invalid deposit amount
                (match (stx-transfer? amount sender (as-contract tx-sender))
                  success (begin
                    (map-set user-savings 
                             { user: sender }
                             { amount: amount, unlock-block: (+ current-block lock-period) })
                    (var-set total-deposits (+ (var-get total-deposits) amount))
                    (ok (tuple (message "Deposit successful")
                               (amount amount)
                               (unlock-block (+ current-block lock-period))))
                  )
                  error (err u104))
                )
            )
          )
      )
    )
  )

;; ----------------------------------------------------
;; Function: withdraw
;; Description: Allows user to withdraw their STX 
;; after the lock period ends
;; ----------------------------------------------------
(define-public (withdraw (block-height-contract <block-height-trait>))
  (let (
         (sender tx-sender)
         (info (map-get? user-savings { user: sender }))
        )
    (if (is-none info)
        (err u102) ;; No deposit found
        (let (
               (data (unwrap-panic info))
               (amount (get amount data))
               (unlock-block (get unlock-block data))
               (current-block (unwrap-panic (contract-call? block-height-contract get-block-height)))
             )
          (if (< current-block unlock-block)
              (err u103) ;; Funds still locked
              (match (stx-transfer? amount (as-contract tx-sender) sender)
                success (begin
                  (map-delete user-savings { user: sender })
                  (var-set total-deposits (- (var-get total-deposits) amount))
                  (ok (tuple (message "Withdrawal successful") (amount amount)))
                )
                error (err u105)
              )
          )
        )
    )
  )
)

;; ----------------------------------------------------
;; Read-only: get-lock-info
;; Returns users deposit amount and unlock block
;; ----------------------------------------------------
(define-read-only (get-lock-info (user principal))
  (default-to 
    { amount: u0, unlock-block: u0 }
    (map-get? user-savings { user: user })
  )
)

;; ----------------------------------------------------
;; Read-only: get-total-deposits
;; Returns total STX locked in the contract
;; ----------------------------------------------------
(define-read-only (get-total-deposits)
  (var-get total-deposits))
