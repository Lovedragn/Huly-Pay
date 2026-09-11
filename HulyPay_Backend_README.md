# Huly.Pay Backend --- Implementation Specification

## Purpose

Build the Spring Boot backend for **Huly.Pay**, a UPI expense-tracking
application.

The backend must provide:

-   Supabase JWT authentication and authorization
-   User synchronization
-   Expense and payment records
-   UPI transaction reconciliation foundation
-   Categories
-   Expense analytics
-   REST APIs for Flutter mobile and React web
-   PostgreSQL persistence
-   Validation, exception handling, logging, and health checks

Frontend clients must **not connect directly to PostgreSQL**. They
communicate through Spring Boot.

## Technology

Use:

-   Java 21
-   Spring Boot 4.1.1
-   Spring Web
-   Spring Security
-   Spring Data JPA
-   Hibernate
-   PostgreSQL
-   Jakarta Bean Validation
-   Lombok
-   Spring Boot Actuator
-   Maven
-   Supabase Auth
-   PostgreSQL 17 locally in Docker
-   Supabase PostgreSQL in production

**Do NOT add Flyway or Liquibase.**

## Package structure

Base package:

``` text
com.hulypay.backend
```

Recommended:

``` text
com.hulypay.backend
├── common
│   ├── HealthController
│   ├── DatabaseHealthController
│   └── exception
├── config
│   └── SecurityConfig
├── users
│   ├── User
│   ├── UserRepository
│   ├── UserService
│   ├── UserController
│   └── dto
├── expenses
│   ├── Expense
│   ├── ExpenseRepository
│   ├── ExpenseService
│   ├── ExpenseController
│   └── dto
├── categories
│   ├── Category
│   ├── CategoryRepository
│   ├── CategoryService
│   └── CategoryController
├── payments
│   ├── Payment
│   ├── PaymentRepository
│   ├── PaymentService
│   └── PaymentController
└── analytics
    ├── AnalyticsService
    └── AnalyticsController
```

Keep Controller, Service, Repository, Entity, DTO, and Config
responsibilities separate.

## Database strategy

### Local development

Use PostgreSQL 17 in Docker:

``` yaml
services:
  postgres:
    image: postgres:17
    container_name: hulypay-postgres
    environment:
      POSTGRES_DB: hulypay
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

Development:

``` text
ddl-auto=update
```

Hibernate may create/update development tables.

### Production

Use Supabase PostgreSQL.

Production:

``` text
ddl-auto=validate
```

Production schema is manually managed for now.

There is intentionally no migration framework.

## application.yml

Use **one `application.yml` only**.

Do not create `application-dev.yml` or `application-prod.yml`.

``` yaml
spring:
  application:
    name: huly-pay-backend

  datasource:
    url: ${DB_URL:jdbc:postgresql://localhost:5432/hulypay}
    username: ${DB_USERNAME:postgres}
    password: ${DB_PASSWORD:postgres}
    driver-class-name: org.postgresql.Driver

  jpa:
    hibernate:
      ddl-auto: ${DDL_AUTO:update}
    open-in-view: false

  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: ${SUPABASE_URL}/auth/v1

server:
  port: 8080

management:
  endpoints:
    web:
      exposure:
        include: health,info

google:
  maps:
    api-key: ${GOOGLE_MAPS_API_KEY}
```

Never hard-code secrets.

## Supabase authentication

Supabase Auth handles:

-   Email/password login
-   Google login
-   GitHub login
-   Access tokens
-   Refresh tokens
-   User identity

Spring Boot validates the Supabase JWT.

Flow:

``` text
Flutter / React
      |
      v
Supabase Auth
      |
      | access_token
      v
Spring Boot API
      |
      | validate JWT
      v
Application
```

Protected requests use:

``` http
Authorization: Bearer <access_token>
```

Spring Security must be configured as an OAuth2 Resource Server.

For this Spring Security version use:

``` java
.oauth2ResourceServer(oauth2 -> oauth2.jwt(jwt -> {}))
```

Do not use the old no-argument `.jwt()`.

## Security requirements

Public:

``` text
GET /api/health
GET /api/health/database
```

Protected:

``` text
/api/v1/**
```

Disable CSRF because this is a stateless REST API.

Do not solve authentication by using:

``` java
.anyRequest().permitAll()
```

All application data must be scoped to the authenticated user.

## JWT identity

The Supabase JWT contains:

``` text
sub
```

This is the Supabase Auth user UUID.

Example:

``` text
6ec86830-d265-489d-80ec-db88f10059c0
```

The backend must obtain identity from the authenticated JWT.

Never trust a client-supplied user ID to determine ownership.

Correct flow:

``` text
JWT -> sub -> application User
```

## Current Supabase authentication test

A test account exists:

``` text
test@hulypay.com
```

Supabase project URL:

``` text
https://aszhhxnbzstzemyhcjvi.supabase.co
```

Do not hard-code this URL. Use:

``` text
SUPABASE_URL
```

The access token has already been verified successfully against
Supabase:

``` text
GET /auth/v1/user
```

using the publishable key and Bearer token.

Current problem:

``` text
GET http://localhost:8080/api/v1/users
```

returns:

``` text
401 Unauthorized
```

Therefore:

``` text
Supabase Auth       = working
Access token        = working
Postman             = working
Spring JWT validation = needs fixing
```

Fix Spring JWT validation correctly. Do not disable security.

Investigate the actual JWT claims/signing configuration:

``` text
iss
aud
sub
role
alg
```

Expected issuer:

``` text
https://aszhhxnbzstzemyhcjvi.supabase.co/auth/v1
```

Never expose or commit a JWT signing secret.

## User synchronization

For an authenticated request:

1.  Read `sub` from the JWT.
2.  Find the local `users` row by that UUID.
3.  Create it if it does not exist.
4.  Update safe profile fields when appropriate.
5.  Continue the request.

User database columns:

``` text
id
email
first_name
last_name
avatar_url
auth_provider
provider_subject
```

The local user ID corresponds to the Supabase Auth UUID.

## User API

Base:

``` text
/api/v1/users
```

Implement:

``` text
GET /api/v1/users/me
```

Identity must come from the JWT.

Example response:

``` json
{
  "id": "6ec86830-d265-489d-80ec-db88f10059c0",
  "email": "test@hulypay.com",
  "firstName": null,
  "lastName": null,
  "avatarUrl": null,
  "authProvider": "email"
}
```

Do not expose credentials or tokens.

## Expense domain

Suggested fields:

``` text
id
user_id
amount
currency
merchant_name
category_id
description
transaction_time
payment_method
upi_transaction_id
status
latitude
longitude
created_at
updated_at
```

Use:

-   UUID for IDs
-   BigDecimal for money
-   Instant or OffsetDateTime for timestamps

Never use `double` or `float` for money.

Default currency:

``` text
INR
```

## Expense ownership

Every expense belongs to one user.

Every expense query must be scoped to the authenticated user.

For:

``` text
GET /api/v1/expenses
```

return only the current user's expenses.

For:

``` text
GET /api/v1/expenses/{id}
```

verify ownership.

Never expose another user's data.

## Expense APIs

Implement:

``` text
POST   /api/v1/expenses
GET    /api/v1/expenses
GET    /api/v1/expenses/{id}
PUT    /api/v1/expenses/{id}
DELETE /api/v1/expenses/{id}
```

Example request:

``` json
{
  "amount": 250.00,
  "currency": "INR",
  "merchantName": "ABC Store",
  "categoryId": "uuid",
  "description": "Groceries",
  "transactionTime": "2026-09-11T12:30:00Z",
  "paymentMethod": "UPI"
}
```

Validate:

-   amount \> 0
-   valid currency
-   merchant/description length
-   category ownership
-   valid timestamp

## UPI payments

Important:

``` text
Client payment result != final trusted transaction state
```

The client must not arbitrarily mark a transaction as successful.

Suggested statuses:

``` text
INITIATED
PENDING
SUCCESS
FAILED
CANCELLED
UNKNOWN
```

Suggested fields:

``` text
id
user_id
expense_id
amount
currency
upi_transaction_id
merchant_name
status
provider
created_at
updated_at
```

Design the payment service so real reconciliation can be added later.

Do not fake payment verification if no real verification provider
exists.

## Categories

Initial categories:

``` text
Food
Travel
Shopping
Bills
Entertainment
Health
Education
Fuel
Rent
Other
```

Support system/default categories and later user-created categories.

APIs:

``` text
GET    /api/v1/categories
POST   /api/v1/categories
PUT    /api/v1/categories/{id}
DELETE /api/v1/categories/{id}
```

Users cannot modify another user's private category.

## Analytics

Implement:

``` text
GET /api/v1/analytics/summary
GET /api/v1/analytics/category-breakdown
GET /api/v1/analytics/daily-spending
GET /api/v1/analytics/monthly-spending
```

Example:

``` json
{
  "totalSpent": 18500.00,
  "transactionCount": 74,
  "averageTransaction": 250.00
}
```

Analytics must be scoped to the authenticated user.

Prefer database aggregation queries rather than loading all expenses
into application memory.

## REST conventions

Base:

``` text
/api/v1
```

Use JSON and correct HTTP status codes:

``` text
200 OK
201 Created
204 No Content
400 Bad Request
401 Unauthorized
403 Forbidden
404 Not Found
409 Conflict
500 Internal Server Error
```

Use DTOs rather than exposing JPA entities directly where practical.

Never return passwords, tokens, credentials, or sensitive internal
information.

## Validation

Use Jakarta Bean Validation:

``` java
@NotNull
@Positive
@Size
@Email
```

Use:

``` java
@Valid
```

on request DTOs.

Return structured validation errors.

Example:

``` json
{
  "status": 400,
  "message": "Validation failed",
  "errors": {
    "amount": "Amount must be greater than zero"
  }
}
```

## Exception handling

Create centralized handling using:

``` text
@RestControllerAdvice
```

Handle:

-   validation errors
-   resource not found
-   authorization errors
-   invalid arguments
-   database conflicts
-   unexpected exceptions

Do not expose stack traces to clients.

## Relationships

Conceptually:

``` text
User
 |
 +---- Expense
 |
 +---- Payment
 |
 +---- Category
```

An expense belongs to one user.

A payment can belong to an expense.

A category can be associated with many expenses.

Do not blindly use:

``` text
CascadeType.ALL
```

especially for user-owned data.

## Timestamps

Use server-generated:

``` text
created_at
updated_at
```

Do not trust client-supplied creation/update timestamps.

Use UTC internally.

## CORS

The API will be used by:

-   Flutter mobile
-   React web dashboard

Do not use unrestricted production CORS.

Do not use `*` for credentialed production requests.

Allow configured frontend origins.

Production web app:

``` text
https://app.hulypay.com
```

Local development should allow the React development origin.

## Environment variables

Expected:

``` text
DB_URL
DB_USERNAME
DB_PASSWORD
DDL_AUTO
SUPABASE_URL
GOOGLE_MAPS_API_KEY
```

Never commit:

``` text
sb_secret_...
service_role keys
database passwords
JWT signing secrets
private credentials
```

Supabase project URL:

``` text
https://<project-ref>.supabase.co
```

Supabase publishable key:

``` text
sb_publishable_...
```

The publishable key is not the hostname.

## Health APIs

Keep:

``` text
GET /api/health
```

Response:

``` json
{
  "status": "UP",
  "message": "Huly.Pay backend is running"
}
```

Keep:

``` text
GET /api/health/database
```

It should verify that the backend can obtain a database connection.

## Testing requirements

Test:

-   public health endpoints
-   missing JWT returns 401
-   invalid JWT returns 401
-   valid Supabase JWT returns 200
-   `/api/v1/users/me` synchronizes the user
-   user isolation
-   expense CRUD
-   amount validation
-   category ownership
-   database access

## Development commands

Start PostgreSQL:

``` powershell
docker compose up -d
```

Run backend:

``` powershell
.\mvnw.cmd spring-boot:run
```

Health:

``` text
GET http://localhost:8080/api/health
```

Database health:

``` text
GET http://localhost:8080/api/health/database
```

## Implementation priority

### Phase 1 --- Authentication foundation

Implement and verify:

``` text
Spring Boot
PostgreSQL
Spring Security
Supabase JWT validation
User synchronization
Health endpoints
```

### Phase 2 --- Core data

Implement:

``` text
Expense CRUD
Categories
Payment records
```

### Phase 3 --- Payments and dashboard

Implement:

``` text
UPI reconciliation
Analytics
Dashboard APIs
```

### Phase 4 --- Production hardening

Later, when required:

``` text
Rate limiting
Caching
Observability
Performance optimization
```

Keep the backend as a **modular monolith**.

Do not introduce microservices, Kafka, or unnecessary infrastructure.

Do not create another authentication server.

## Definition of done

-   [ ] Spring Boot starts
-   [ ] PostgreSQL connection works
-   [ ] `/api/health` works
-   [ ] `/api/health/database` works
-   [ ] Supabase JWT validation works
-   [ ] Missing/invalid JWT returns 401
-   [ ] Valid JWT returns 200
-   [ ] `/api/v1/users/me` synchronizes the Supabase user
-   [ ] User data is isolated
-   [ ] Expense CRUD works
-   [ ] Categories work
-   [ ] Payment model exists
-   [ ] Validation works
-   [ ] Global exception handling works
-   [ ] Authentication/user-isolation tests exist
-   [ ] No Flyway/Liquibase exists
-   [ ] No secrets are committed
-   [ ] Only one `application.yml` is used
-   [ ] Local PostgreSQL uses `ddl-auto=update`
-   [ ] Production can use `ddl-auto=validate`

## Instructions to Antigravity

You are implementing the Huly.Pay Spring Boot backend.

Before modifying code:

1.  Inspect the existing project.
2.  Preserve working code.
3.  Do not introduce Flyway or Liquibase.
4.  Do not create profile-specific YAML files.
5.  Use environment variables for environment-specific configuration.
6.  Do not hard-code credentials.
7.  Fix the existing Supabase JWT authentication issue first.
8.  Run the project after changes.
9.  Run tests.
10. Report exactly which files were created/modified.
11. Report any remaining configuration required from the developer.

Do not merely explain what should be done. **Actually implement the
backend code.**

If a requirement is ambiguous, prefer the simplest secure implementation
consistent with this document and the existing project.

At the end, report:

``` text
1. Files changed
2. Commands to run
3. Environment variables required
4. API endpoints implemented
5. Tests performed
6. Remaining manual Supabase configuration
```
