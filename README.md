# GeneVault Smart Contract

## Overview

GeneVault is a decentralized genomic data marketplace that enables individuals to securely share their genomic data with verified scientists. It ensures data protection, access control, and researcher verification within a transparent blockchain environment.

## Features

* **Genome Registration:** Users can upload encrypted genome data and metadata with defined access costs.
* **Scientist Registration:** Researchers register their credentials, organization, and qualifications for verification.
* **Access Requests:** Scientists can request access to specific genomic datasets.
* **Access Approval:** Genome holders approve or deny scientist requests.
* **Verification System:** Contract admin verifies legitimate scientists.
* **Reputation Management:** Admin updates trust scores based on verified contributions and conduct.
* **Read-only Queries:** Retrieve genome details, scientist profiles, and access status.

## Functions

### Genome Management

* `register-genome(encrypted-genome-hash, metadata-hash, cost)`
  Registers a new genome dataset after validating cost and data integrity.

### Scientist Management

* `register-scientist(name, organization, qualifications)`
  Registers a scientist’s identity and credentials.

### Access Control

* `request-access(genome-id)`
  Allows scientists to request access to a genome.
* `approve-access(genome-id, query-id)`
  Grants genome access to approved scientists.

### Verification and Reputation

* `verify-scientist(scientist)`
  Admin-only function to verify registered scientists.
* `update-reputation(scientist, rating)`
  Updates a scientist’s trust score.

### Data Retrieval

* `get-genome-details(genome-id)`
  Returns stored genome information.
* `get-scientist-profile(scientist)`
  Fetches scientist profile data.
* `get-access-status(genome-id, scientist)`
  Checks if a scientist has access to a genome.

## Access Control

* Genome holders manage access to their data.
* Contract admin holds verification and rating authority.

## Error Codes

* `ERR-UNAUTHORIZED (u1)` Unauthorized action
* `ERR-INVALID-GENOME (u2)` Invalid genome ID
* `ERR-ALREADY-HANDLED (u3)` Duplicate processing
* `ERR-TRANSACTION-FAILED (u4)` Operation failure
* `ERR-INVALID-ARGS (u5)` Invalid arguments
* `ERR-INVALID-COST (u6)` Cost out of range
* `ERR-INVALID-QUERY (u7)` Invalid query ID
* `ERR-SCIENTIST-NOT-FOUND (u8)` Scientist not registered
* `ERR-INVALID-RATING (u9)` Rating beyond range

## Governance

* The contract admin oversees scientist verification and reputation management.
* Genome data remains user-controlled, ensuring autonomy and security.
