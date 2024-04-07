#lang racket/base

(require csv-reading racket/match racket/string
         racket/list string-interpolation
         racket/format text-table)

(define accounts-filename
  "ACCOUNTS.TXT")

(define transactions-filename
  "TRANSACTIONS.TXT")

(define statement-filename
  "STATEMENTS.TXT")

;; This reads accounts. I had to massage the input a bit to get it to split into three columns
(define (read-lines-from-file filename)
  (with-input-from-file filename
    (lambda ()
      (let loop ((lines '()))
        (let ([line (read-line)])
          (if (eof-object? line)
              (reverse lines)
              (begin                
                (loop (cons
                       (map string-trim
                            (string-split
                             (string-replace
                              (string-normalize-spaces line) "\"" "," ) "," #:trim? #t))
                       lines)))))))))

;; This read the transactions just fine, but would not give me good results when reading accounts
(define (csvfile->list filename reader)
  (call-with-input-file filename
    (lambda (input-port)
      (csv->list (reader input-port)))))

;; A reader I meant to use for both accounts and transactions, but I kept getting garbage results
;; when reading accounts. Hence the above function
(define csv-reader-trimmed
  (make-csv-reader-maker
   '((separator-chars            #\tab #\space)
     (strip-leading-whitespace?  . #t)
     (strip-trailing-whitespace? . #t)))
  )

(struct account
  (number name balance)
  #:transparent)

;; Takes a list of data corresponding to accounts and transforms them to account structs
(define (convert-to-account-structs accounts)
  (define (create-account-struct account-data)
    (match account-data
      [(list account-number name balance)
       (account
        account-number
        name      
        balance)]
      [_ (error "Failed to create account")]
      ))
  (map create-account-struct accounts))

(struct purchase
  (account-number timestamp vendor amount)
  #:transparent)

;; Takes a list of data corresponding to purchases and transforms them to purchase structs
(define (convert-to-purchase-structs purchases)
  (define (create-purchase-struct purchase-data)
    (match purchase-data
      [(list _ account-number timestamp vendor amount)
       (purchase
        account-number
        timestamp
        vendor
        amount)]
      [_ (error "Failed to create purchase")]
      ))
  (map create-purchase-struct purchases))

(struct cash-payment
  (account-number timestamp amount)
  #:transparent)

;; Takes a list of data corresponding to cash payments and transforms them to account structs
(define (convert-to-cash-payment-structs payments)
  (define (create-cash-payment-struct cash-payment-data)
    (match cash-payment-data
      [(list _ account-number timestamp _ amount)
       (cash-payment
        account-number
        timestamp
        amount)]
      [_ (error "Failed to create cash payment")]
      ))
  (map create-cash-payment-struct payments))


(struct check-payment
  (account-number timestamp check-number amount)
  #:transparent)

;; Takes a list of data corresponding to check payments and transforms them to check-payment structs
(define (convert-to-check-payment-structs payments)
  (define (create-check-payment-struct check-payment-data)
    (match check-payment-data
      [(list _ account-number timestamp _ check-number amount)
       (check-payment
        account-number
        timestamp
        check-number
        amount)]
      [_ (error "Failed to create check payment")]
      ))
  (map create-check-payment-struct payments))


(struct credit-payment
  (account-number timestamp card-number amount)
  #:transparent)

;; Takes a list of data corresponding to credit payments and transforms them to credit-payment structs
(define (convert-to-credit-payment-structs payments)
  (define (create-credit-payment-struct credit-payment-data)
    (match credit-payment-data
      [(list _ account-number timestamp _ card-number amount)
       (credit-payment
        account-number
        timestamp
        card-number
        amount)]
      [_ (error "Failed to create credit payment")]
      ))
  (map create-credit-payment-struct payments))

(struct debit-payment
  (account-number timestamp card-number amount)
  #:transparent)

;; Takes a list of data corresponding to debit payments and transforms them to debit-payment structs
(define (convert-to-debit-payment-structs payments)
  (define (create-debit-payment-struct debit-payment-data)
    (match debit-payment-data
      [(list _ account-number timestamp _ card-number amount)
       (debit-payment
        account-number
        timestamp
        card-number
        amount)]
      [_ (error "Failed to create debit payment")]
      ))
  (map create-debit-payment-struct payments))

;; This reads the strings read in through the reader and converts tags back into place where necessary
;; It also converts money strings into decimal numbers
(define (convert-strings-to-actual-values lst)
  (define (replace str)
    (cond
      [(string-ci=? str "purchase") 'Purchase]
      [(string-ci=? str "payment") 'Payment]
      [(string-ci=? str "cash") 'Cash]
      [(string-ci=? str "check") 'Check]
      [(string-ci=? str "credit") 'Credit]
      [(string-ci=? str "debit") 'Debit]
      ;; Check for a decimal point and ignores strings that can't be numbers. The latter is to avoid
      ;; attempts to convert names with periods into numbers
      [(and (regexp-match? #rx"\\." str)
            (string->number str))
       (string->number str)] ; Convert string with decimal point to number
      [else str]))

  (map (lambda (sublist) (map replace sublist)) lst))

;; This checks a list recursively for a specified tag exists within it
(define contains-tag?
  (lambda (tag sublist)
    (cond
      [(empty? sublist) #f]
      [(eq? tag (first sublist)) #t]
      [else (contains-tag? tag (rest sublist))])))

;; This filters a list that has a specified tag using contains-tag above
(define find-list-with-tag
  (lambda (tag list-of-lists)
    (filter (lambda (sublist) (contains-tag? tag sublist)) list-of-lists)))

;; All check, cash, credit and debit transactions are payments.
;; This confirms a given struct is one of these
(define (payment? transaction)
  (cond
    [(cash-payment? transaction) #t]
    [(check-payment? transaction) #t]
    [(credit-payment? transaction) #t]
    [(debit-payment? transaction) #t]
    [else #f])  )

;; Returns a struct's account number. It accepts any transactional struct
(define (get-account-number transaction)
  (cond
    [(purchase? transaction) (purchase-account-number transaction)]
    [(cash-payment? transaction) (cash-payment-account-number transaction)]
    [(check-payment? transaction) (check-payment-account-number transaction)]
    [(credit-payment? transaction) (credit-payment-account-number transaction)]
    [(debit-payment? transaction) (debit-payment-account-number transaction)]
    [else (error "Not a transaction")]))

;; Returns a struct's timestamp. It accepts any transactional struct
(define (get-timestamp transaction)
  (cond
    [(purchase? transaction) (purchase-timestamp transaction)]
    [(cash-payment? transaction) (cash-payment-timestamp transaction)]
    [(check-payment? transaction) (check-payment-timestamp transaction)]
    [(credit-payment? transaction) (credit-payment-timestamp transaction)]
    [(debit-payment? transaction) (debit-payment-timestamp transaction)]
    [else (error "Not a transaction")]))

;; Returns a struct's amount. It accepts any transactional struct
;; Transactions are defined as positive amounts.
;; Zero is returned if a negative amount is found
(define (get-amount transaction)
  (cond
    [(and (purchase? transaction)
          (positive? (purchase-amount transaction))
          (purchase-amount transaction))]
    [(and (cash-payment? transaction)
          (positive? (cash-payment-amount transaction))
          (cash-payment-amount transaction))]
    [(and (check-payment? transaction)
          (positive? (check-payment-amount transaction))
          (check-payment-amount transaction))]
    [(and (credit-payment? transaction)
          (positive? (credit-payment-amount transaction))
          (credit-payment-amount transaction))]
    [(and (debit-payment? transaction)
          (positive? (debit-payment-amount transaction))
          (debit-payment-amount transaction))]
    [else 0]))

;; Sorts a list of transactions by their timestamps
(define (sort-by-timestamp transactions)
  (sort transactions
        (lambda (transaction1 transaction2)
          (string<? (get-timestamp transaction1) (get-timestamp transaction2)))))

;; Recursively sums purchases and payments from a mixed list of them
(define (sum-amounts transactions)
  (define (sum-amounts-helper lst purchase-sum payment-sum)
    (cond
      ;; base case: returns summed values
      [(empty? lst) (list purchase-sum payment-sum)]
      [(purchase? (car lst))
       (sum-amounts-helper (cdr lst)
                           (+ purchase-sum (purchase-amount (car lst)))
                           ;; pass existing payment total if not a purchase
                           payment-sum)]
      [(payment? (car lst))
       (sum-amounts-helper (cdr lst)
                           ;; pass existing purchase total if not a payment
                           purchase-sum
                           (+ payment-sum (get-amount (car lst))
                              ))]))
  (sum-amounts-helper transactions 0 0))

;; Returns the first num characters from a string
(define (first-characters str num)
  (substring str 0 (min num (string-length str))))

;; Pads a column with soft and hard caps
;; going over the hard cap will truncate a string at that length
;; going over soft cap but under the hard cap will return the string itself
;; under the soft cap will pad the end of the string to make it equal to the soft cap
(define (pad-column str soft-cap hard-cap)
  (cond
    [(>= (string-length str) hard-cap) (first-characters str hard-cap)]
    ;; If the string is already longer than the soft cap, return it as is
    [(>= (string-length str) soft-cap) str]
    ;; pads up to soft cap
    [else (string-append str (make-string (- soft-cap (string-length str)) #\space))]))  

;; takes an account and formats it to be used by a table
(define (format-account account)
  (cond
    [(account? account)
       (list (list "@{(account-number account)}      "
             "@{(account-name account)}  "
             "Starting Balance: @{(account-balance account)}" ))]
    [else (error "Not an account")]))

;; takes a formatted table of accounts and prints them
(define (print-accounts-table account)
(displayln
   (simple-table->string
    #:align '(left left left)
    (format-account account)
    ))
  )

;; Takes a string and returns the last four digits. Mainly used for card number printing
(define (last-four-characters str)
  (substring str (- (string-length str) 4)))

;; Takes a transaction and formats it to fit into a table
(define (format-transaction transaction)
  (cond
    [(purchase? transaction)
     (list "@{(purchase-timestamp transaction)}  "
           "Purchase   "
           (pad-column "@{(purchase-vendor transaction)}" 20 40)           
           "@{(format-positive-currency(purchase-amount transaction))}")]
    [(cash-payment? transaction)
     (list "@{(cash-payment-timestamp transaction)}  "
           "Payment   "
           (pad-column "Cash" 20 40)
           "@{(format-positive-currency(cash-payment-amount transaction))}")]
    [(check-payment? transaction)
     (list "@{(check-payment-timestamp transaction)}  "
           "Payment   "
           (pad-column "Check #@{(check-payment-check-number transaction)}" 20 40)
           "@{(format-positive-currency(check-payment-amount transaction))}")]
    [(credit-payment? transaction)
     (list "@{(credit-payment-timestamp transaction)}  "
           "Payment   "
           (pad-column "Credit *@{(last-four-characters(credit-payment-card-number transaction))}" 20 40)
           "@{(format-positive-currency(credit-payment-amount transaction))}")]
    [(debit-payment? transaction)
     (list "@{(debit-payment-timestamp transaction)}  "
           "Payment   "
           (pad-column "Debit *@{(last-four-characters(debit-payment-card-number transaction))}" 20 40)
           "@{(format-positive-currency(debit-payment-amount transaction))}")]
    [else (error "Not a transaction")]))

;; prints a list of formatted transactions as a table
(define (print-transactions-table lst)
(displayln
   (simple-table->string
    #:align '(left left left right)
    (map format-transaction lst)
    ))
  )

;; formats a list of totals for output as a table
(define (format-totals account totals)
  (list
   (list (pad-column "Total Purchases:" 20 25)
         "@{(format-currency(first totals))}")
   (list (pad-column "Total Payments:" 20 25)
         "@{(format-currency(second totals))}") 
   (list (pad-column "Ending Balance:" 20 25)
         "@{(format-currency(+ (account-balance account) (foldr - 0 totals)))}"))
  )
;; prints a formatted total table
(define (print-totals-table account totals)
(displayln
   (simple-table->string
    #:align '(left right)
    (format-totals account totals)
    ))
  )

;; formats a number as currency by limiting decimal points
(define (format-currency number)  
    (~r number #:precision '(= 2))    
  )
;; Calls format-currency, but marks negatives as Invalid
(define (format-positive-currency number)
  (if (or (positive? number))
          (format-currency number)
    "@{(format-currency number)} (Invalid)")
)

;; prints an account statement for an individual account
(define (print-statement account transactions totals)
  (displayln "STATEMENT OF ACCOUNT")
  (print-accounts-table account)
  (displayln "")

  (print-transactions-table transactions)

  (displayln "" )
  (print-totals-table account totals)
  (displayln "*********************************************************")
  )

;; Recursively traverses through the list of accounts, filters out transactions not associated with the
;; account, and calculates their totals. Sends this data to print-statement
(define (display-results accounts transactions)
  (cond
    [(empty? accounts)]
    [(let* ([account (first accounts)]
            [account-transactions (filter (lambda (transaction)
                                            (equal? (get-account-number transaction) (account-number account)))
                                          transactions)]
            [totals (sum-amounts account-transactions)]
            )
       (print-statement account account-transactions totals)
       (display-results (rest accounts) transactions)
       )
     ])
  )

;; Loads the files and creates structs based on the tags contained within them.
(define (create-transaction-data-list)
  (let* ([transaction-lines
          (convert-strings-to-actual-values (csvfile->list transactions-filename csv-reader-trimmed))]
         [payments
          (find-list-with-tag 'Payment transaction-lines)])
    (let ([accounts
           (convert-to-account-structs
            (convert-strings-to-actual-values
             (read-lines-from-file accounts-filename)))]
          [purchases
           (convert-to-purchase-structs (find-list-with-tag 'Purchase transaction-lines))]           
          [cash-payments
           (convert-to-cash-payment-structs (find-list-with-tag 'Cash payments))]
          [check-payments
           (convert-to-check-payment-structs (find-list-with-tag 'Check payments))]
          [credit-payments
           (convert-to-credit-payment-structs (find-list-with-tag 'Credit payments))]
          [debit-payments
           (convert-to-debit-payment-structs (find-list-with-tag 'Debit payments))]
          )
      (let* ([sorted-transactions
             (sort-by-timestamp
              (append purchases cash-payments check-payments credit-payments debit-payments))]            
            )
        (with-output-to-file
            statement-filename #:exists 'truncate
          (lambda ()
            (display-results (sort accounts string<? #:key account-number)
                             sorted-transactions))
          )))
    ))



(create-transaction-data-list)