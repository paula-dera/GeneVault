;; Genomic Data Marketplace
;; Implements a decentralized marketplace for genomic data

;; Constants
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-INVALID-GENOME (err u2))
(define-constant ERR-ALREADY-HANDLED (err u3))
(define-constant ERR-TRANSACTION-FAILED (err u4))
(define-constant ERR-INVALID-ARGS (err u5))
(define-constant ERR-INVALID-COST (err u6))
(define-constant ERR-INVALID-QUERY (err u7))
(define-constant ERR-SCIENTIST-NOT-FOUND (err u8))
(define-constant ERR-INVALID-RATING (err u9))

;; Configuration Constants
(define-constant MAX-COST u1000000000000) ;; 1 million STX
(define-constant MAX-QUERY-ID u1000000)

;; Data Variables
(define-data-var total-genomes uint u0)

;; Maps
(define-map genomes
    uint
    {
        owner: principal,
        enc-genome-hash: (string-utf8 256),
        meta-hash: (string-utf8 256),
        cost: uint,
        accessible: bool
    }
)

(define-map genome-access {gid: uint, sci: principal} bool)

(define-map scientists
    principal
    {
        name: (string-utf8 100),
        organization: (string-utf8 100),
        qualifications: (string-utf8 256),
        verified: bool,
        rep-score: uint
    }
)

(define-map access-queries
    {gid: uint, qid: uint}
    {
        sci: principal,
        approved: bool,
        processed: bool
    }
)

(define-map scientist-contributions principal uint)

;; Governance
(define-data-var admin principal tx-sender)

;; Validation Functions
(define-private (validate-cost (cost uint))
    (and (> cost u0) (<= cost MAX-COST)))

(define-private (validate-query-id (qid uint))
    (<= qid MAX-QUERY-ID))

(define-private (validate-scientist (sci principal))
    (is-some (map-get? scientists sci)))

(define-private (validate-rating (rating uint))
    (<= rating u100))

;; Authorization check
(define-private (is-contract-admin)
    (is-eq tx-sender (var-get admin)))

;; Dataset Management
(define-public (register-genome 
    (enc-genome-hash (string-utf8 256))
    (meta-hash (string-utf8 256))
    (cost uint))
    (let
        ((gid (var-get total-genomes)))
        (asserts! (validate-cost cost) ERR-INVALID-COST)
        (asserts! (and
            (> (len enc-genome-hash) u0)
            (> (len meta-hash) u0))
            ERR-INVALID-ARGS)
        
        (begin
            (map-set genomes gid
                {
                    owner: tx-sender,
                    enc-genome-hash: enc-genome-hash,
                    meta-hash: meta-hash,
                    cost: cost,
                    accessible: true
                })
            (var-set total-genomes (+ gid u1))
            (ok gid))))

;; Researcher Registration
(define-public (register-scientist 
    (name (string-utf8 100))
    (organization (string-utf8 100))
    (qualifications (string-utf8 256)))
    (if (and
            (> (len name) u0)
            (> (len organization) u0)
            (> (len qualifications) u0))
        (begin
            (map-set scientists tx-sender
                {
                    name: name,
                    organization: organization,
                    qualifications: qualifications,
                    verified: false,
                    rep-score: u0
                })
            (ok true))
        ERR-INVALID-ARGS))

;; Access Management
(define-public (request-access (gid uint))
    (let ((genome (unwrap! (map-get? genomes gid) ERR-INVALID-GENOME)))
        (if (get accessible genome)
            (begin
                (map-set access-queries 
                    {gid: gid, qid: u0}
                    {
                        sci: tx-sender,
                        approved: false,
                        processed: false
                    })
                (ok true))
            ERR-INVALID-GENOME)))

(define-public (approve-access (gid uint) (qid uint))
    (let
        (
            (genome (unwrap! (map-get? genomes gid) ERR-INVALID-GENOME))
            (query (unwrap! (map-get? access-queries {gid: gid, qid: qid}) ERR-INVALID-GENOME))
        )
        (asserts! (validate-query-id qid) ERR-INVALID-QUERY)
        (asserts! (and
            (is-eq (get owner genome) tx-sender)
            (not (get processed query)))
            ERR-UNAUTHORIZED)
        
        (begin
            (map-set access-queries
                {gid: gid, qid: qid}
                {
                    sci: (get sci query),
                    approved: true,
                    processed: true
                })
            (map-set genome-access
                {gid: gid, sci: (get sci query)}
                true)
            (ok true))))

;; Researcher Verification
(define-public (verify-scientist (sci principal))
    (begin
        (asserts! (is-contract-admin) ERR-UNAUTHORIZED)
        (asserts! (validate-scientist sci) ERR-SCIENTIST-NOT-FOUND)
        
        (match (map-get? scientists sci)
            scientist-data (begin
                (map-set scientists sci
                    (merge scientist-data {verified: true}))
                (ok true))
            ERR-INVALID-ARGS)))

;; Reputation Management
(define-public (update-reputation (sci principal) (rating uint))
    (begin
        (asserts! (is-contract-admin) ERR-UNAUTHORIZED)
        (asserts! (validate-scientist sci) ERR-SCIENTIST-NOT-FOUND)
        (asserts! (validate-rating rating) ERR-INVALID-RATING)
        
        (match (map-get? scientists sci)
            scientist-data (begin
                (map-set scientists sci
                    (merge scientist-data {rep-score: rating}))
                (ok true))
            ERR-INVALID-ARGS)))

;; Read-only functions
(define-read-only (get-genome-details (gid uint))
    (map-get? genomes gid))

(define-read-only (get-scientist-profile (sci principal))
    (map-get? scientists sci))

(define-read-only (get-access-status (gid uint) (sci principal))
    (default-to false
        (map-get? genome-access {gid: gid, sci: sci})))