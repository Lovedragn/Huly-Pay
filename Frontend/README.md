# Huly.Pay

> A modern expense-intelligence layer around UPI payments.

Huly.Pay is a mobile application + desktop web dashboard designed to make everyday UPI spending easier to track, understand, and analyze.

The application does **not** replace Google Pay or move money itself. Huly.Pay creates the payment context, launches the user's UPI payment application with the merchant and requested amount, receives the payment result, verifies/reconciles the transaction, and stores the resulting expense for analytics.

---

## Table of Contents

- [Product Vision](#product-vision)
- [Core User Flow](#core-user-flow)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Flutter Architecture](#flutter-architecture)
- [Backend Architecture](#backend-architecture)
- [Payment Architecture](#payment-architecture)
- [Merchant and QR Resolution](#merchant-and-qr-resolution)
- [Database Design](#database-design)
- [Expense Grouping](#expense-grouping)
- [30-Minute Payment Expiration](#30-minute-payment-expiration)
- [Analytics Dashboard](#analytics-dashboard)
- [Authentication](#authentication)
- [Google Maps and Places](#google-maps-and-places)
- [Security](#security)
- [API Design](#api-design)
- [Project Structure](#project-structure)
- [Deployment](#deployment)
- [MVP Roadmap](#mvp-roadmap)
- [Important Design Decisions](#important-design-decisions)
- [Example Payment Flow](#example-payment-flow)

---

## Product Vision

Huly.Pay is intended to feel like a **smart skin around the user's normal UPI payment workflow**.

Instead of asking users to manually enter every expense after paying, Huly.Pay captures useful payment context before and during the payment flow:

- Merchant information from the scanned QR code
- UPI merchant identifier
- Merchant category / MCC information
- User location at scan time
- Google Places information where the merchant can be resolved
- Payment amount
- Payment transaction reference
- Payment result and reconciliation state
- Expense category
- User notes and grouping preferences

The captured information becomes the foundation for a useful personal finance dashboard.

---

## Chosen Infrastructure

The initial deployment is designed around low-cost/free-tier services:

| Concern | Choice |
|---|---|
| Mobile app | Flutter |
| Web dashboard | Flutter Web |
| Backend | Java + Spring Boot |
| Database | **Supabase PostgreSQL (Free tier)** |
| Web hosting | **Vercel (Free tier)** |
| Domain / DNS / optional landing site | **Hostinger** |
| Local mobile storage | SQLite + Drift |
| Maps / Places | Google Maps Platform |
| Source control | GitHub |
| CI/CD | GitHub Actions |

Supabase is the persistent PostgreSQL database layer. Vercel hosts the Flutter Web dashboard. Hostinger can manage the project domain/DNS and can optionally host a separate landing page. The Spring Boot API remains an independent component so its hosting provider can be changed later without redesigning the application.

---

## Core User Flow

Example: **User wants to buy ₹300 worth of candy from LOLOO STORE.**

```text
User opens Huly.Pay
        |
        v
Scan LOLOO STORE UPI QR
        |
        +--> Decode merchant VPA / name / MCC / QR data
        |
        +--> Gather device location
        |
        +--> Resolve merchant through Google Places when possible
        |
        v
Create Payment Attempt
status = PENDING
expires_at = now + 30 minutes
        |
        v
User enters ₹300
        |
        v
Huly.Pay creates transaction reference
        |
        v
Launch Google Pay / UPI payment flow
        |
        v
User confirms and enters UPI PIN
        |
        v
UPI / bank processes payment
        |
        v
Google Pay returns payment result
        |
        v
Backend verifies / reconciles payment
        |
        +--> SUCCESS
        +--> FAILED
        +--> RECONCILIATION_REQUIRED
        +--> EXPIRED
        |
        v
Create / finalize expense
        |
        v
Dashboard and analytics update
```

---

## Architecture

Huly.Pay will use a shared backend for both the Flutter mobile application and Flutter web dashboard.

```text
                         +-------------------------+
                         |        Huly.Pay         |
                         |      Flutter Mobile     |
                         +------------+------------+
                                      |
                                      | HTTPS / REST
                                      v
                         +-------------------------+
                         |      Spring Boot API     |
                         +------------+------------+
                                      |
             +------------------------+------------------------+
             |                        |                        |
             v                        v                        v
      +-------------+          +-------------+          +-------------+
      | Supabase    |          |    Redis    |          | Background  |
      | PostgreSQL  |          |             |          | Jobs        |
      | Users       |          | Cache       |          | Expiration  |
      | Merchants   |          | Sessions    |          | Reconcile   |
      | Payments    |          | Rate limits |          | Analytics   |
      | Expenses    |          |             |          |             |
      +-------------+          +-------------+          +-------------+
                                      |
              +-----------------------+-----------------------+
              |                       |                       |
              v                       v                       v
       +-------------+         +-------------+         +-------------+
       | Google Maps |         | Auth        |         | UPI / PSP / |
       | Places      |         | Google      |         | Payment     |
       |             |         | GitHub      |         | Verification|
       +-------------+         +-------------+         +-------------+

                         +-------------------------+
                         |  Flutter Web Dashboard  |
                         +------------+------------+
                                      |
                                      | HTTPS / REST
                                      v
                              Spring Boot API
```

### Architectural Style

The first release should use a **modular monolith**, not a large microservice architecture.

Benefits:

- Faster development
- Easier local setup
- Easier debugging
- Single transaction boundary for payment and expense operations
- Simple deployment
- Can later be split into services if scale requires it

---

## Technology Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter |
| Desktop Web Dashboard | Flutter Web |
| Language | Dart |
| State Management | Riverpod |
| Navigation | go_router |
| HTTP Client | Dio |
| Local Database | SQLite + Drift |
| Backend | Java + Spring Boot |
| API | REST |
| Database | **Supabase PostgreSQL (Free tier)** |
| Cache | Redis (add later when needed) |
| Authentication | Firebase Auth / OAuth providers |
| Maps | Google Maps Platform |
| Places | Google Places API |
| Payments | UPI intent / Google Pay integration |
| Scheduling | Spring Scheduler initially |
| Containers | Docker |
| Reverse Proxy | Nginx |
| CI/CD | GitHub Actions |
| Monitoring | Sentry + structured backend logs |

---

## Flutter Architecture

The mobile application and web dashboard should follow feature-based Clean Architecture.

```text
Flutter UI
    |
    v
Riverpod Provider / Controller
    |
    v
Use Case
    |
    v
Repository
    |
    +-----------------------+
    |                       |
    v                       v
Remote Data Source     Local Data Source
    |                       |
    v                       v
Spring Boot API         SQLite / Drift
```

### Recommended Mobile Project Structure

```text
mobile/
└── lib/
    ├── app/
    │   ├── app.dart
    │   ├── router.dart
    │   ├── theme.dart
    │   └── dependencies.dart
    │
    ├── core/
    │   ├── network/
    │   ├── storage/
    │   ├── errors/
    │   ├── constants/
    │   ├── utils/
    │   └── widgets/
    │
    └── features/
        ├── auth/
        ├── home/
        ├── scanner/
        ├── payment/
        ├── expenses/
        ├── analytics/
        ├── merchants/
        ├── budget/
        ├── profile/
        └── settings/
```

---

## Backend Architecture

The initial Spring Boot backend should be organized by business capability.

```text
backend/
└── src/main/java/com/hulypay/
    ├── auth/
    ├── users/
    ├── merchants/
    ├── qr/
    ├── payments/
    ├── expenses/
    ├── categories/
    ├── analytics/
    ├── budget/
    ├── places/
    ├── notifications/
    └── common/
```

A typical request flows through:

```text
Controller
   -> Service
      -> Domain / Business Logic
         -> Repository
            -> PostgreSQL
```

For payment operations:

```text
PaymentController
       |
       v
PaymentService
       |
       v
PaymentOrchestrator
       |
       +--> UPI / GPay launcher metadata
       |
       +--> PSPVerificationService
       |
       +--> ExpenseService
       |
       v
PostgreSQL
```

---

## Payment Architecture

### Payment State Machine

Payment processing must be modeled as a state machine.

```text
                 +-----------+
                 |  CREATED  |
                 +-----+-----+
                       |
                       v
                 +-----------+
                 |  PENDING  |
                 +-----+-----+
                       |
          +------------+-------------+
          |            |             |
          v            v             v
      +-------+     +-------+    +---------+
      |SUCCESS|     |FAILED |    | EXPIRED |
      +---+---+     +-------+    +---------+
          |
          v
   +---------------+
   | EXPENSE       |
   | CREATED       |
   +---------------+

Possible additional state:

PENDING -> RECONCILIATION_REQUIRED
```

### Important Rule

Huly.Pay should **not trust only the client-side Google Pay result** when deciding that an expense is successfully paid.

The intended flow is:

```text
Google Pay result
       |
       v
Huly.Pay backend
       |
       v
PSP / aggregator / payment verification
       |
       +--> Verify transaction reference
       +--> Verify amount
       +--> Verify merchant
       +--> Verify payment status
       |
       v
Final payment state
```

This keeps the backend authoritative and reduces the risk of client-side manipulation.

### UPI URI

A UPI payment request can conceptually contain fields such as:

```text
upi://pay
    ?pa=merchant@bank
    &pn=LOLOO
    &mc=5411
    &tr=HULY-20260910-ABCD1234
    &tn=Candy%20Purchase
    &am=300.00
    &cu=INR
```

The exact behavior of the destination UPI application remains under the control of the UPI/payment application. Huly.Pay should therefore treat its requested amount as the intended amount and verify the resulting transaction after the payment attempt.

### Android / Flutter Boundary

The Flutter application can own the payment orchestration UI, while Android-specific UPI launching can be isolated behind a platform abstraction.

```text
Flutter
   |
   v
PaymentRepository
   |
   v
Payment Platform Service
   |
   v
Android Platform Channel / UPI Intent
   |
   v
Google Pay / UPI App
```

---

## Merchant and QR Resolution

A QR code should not automatically be assumed to correspond to a unique Google Maps place.

### Resolution Pipeline

```text
                QR Code
                   |
                   v
            Decode UPI data
                   |
       +-----------+-----------+
       |           |           |
       v           v           v
      VPA        Merchant      MCC
                  Name
       \           |           /
        \          |          /
         +---------+---------+
                   |
                   v
             Device GPS
                   |
                   v
          Google Places search
                   |
                   v
            Candidate places
                   |
                   v
           Merchant resolver
                   |
                   v
          Best matching Place
```

The resolver can use:

- Merchant name similarity
- Distance from scan coordinates
- Merchant category / MCC
- Address matching
- Existing VPA-to-place relationships
- Previously resolved merchant information

### Merchant Data

```text
merchants
-------------------------
id
name
upi_vpa
mcc
category
google_place_id
address
latitude
longitude
rating
maps_uri
created_at
updated_at
```

---

## Database Design

PostgreSQL is the authoritative system of record.

SQLite on the mobile device is only a local cache / offline store.

### Users

```text
users
-------------------------
id UUID PRIMARY KEY
email
first_name
last_name
avatar_url
auth_provider
provider_subject
created_at
updated_at
```

### User Preferences

```text
user_preferences
-------------------------
user_id
monthly_target
monthly_limit
currency
theme
animations_enabled
created_at
updated_at
```

### Payment Methods / Displayed UPI Identity

```text
payment_methods
-------------------------
id
user_id
provider
upi_handle
display_name
is_default
created_at
```

Do not store UPI PINs, banking passwords, or equivalent sensitive credentials.

### Merchants

```text
merchants
-------------------------
id
name
upi_vpa
mcc
category
google_place_id
address
latitude
longitude
rating
maps_uri
created_at
updated_at
```

### Payment Attempts

```text
payment_attempts
-------------------------
id UUID
user_id
merchant_id
transaction_ref
requested_amount
currency
status
gpay_response
provider_reference
created_at
expires_at
completed_at
```

### Expenses

```text
expenses
-------------------------
id UUID
user_id
payment_attempt_id
merchant_id
amount
category_id
transaction_date
note
group_id
created_at
updated_at
```

### Categories

Suggested starting categories:

- Food
- Clothing
- Shopping
- Mall
- Government
- Network
- Subscriptions
- Transport
- Health
- Entertainment
- Education
- Travel
- Other

---

## Expense Grouping

If a user makes multiple payments at the same merchant within a chosen period, Huly.Pay can optionally display them as one grouped expense.

The raw payment records must remain independent.

Example:

```text
LOLOO STORE

10:02 AM  ₹300
10:08 AM  ₹150
10:17 AM  ₹200

------------------
Grouped total: ₹650
```

Use a separate table:

```text
expense_groups
-------------------------
id
user_id
merchant_id
start_time
end_time
display_title
```

Then:

```text
expenses.group_id -> expense_groups.id
```

This preserves transaction accuracy while allowing a cleaner UI.

---

## 30-Minute Payment Expiration

A payment attempt should have an explicit expiration timestamp.

```text
created_at = 10:00
expires_at = 10:30
```

A background worker can find expired pending attempts:

```sql
SELECT *
FROM payment_attempts
WHERE status = 'PENDING'
  AND expires_at < NOW();
```

Then transition them to:

```text
PENDING -> EXPIRED
```

It is preferable to mark payment attempts as `EXPIRED` rather than immediately deleting them. A later reconciliation event may otherwise be impossible to associate with the original attempt.

A separate retention policy can permanently remove old temporary payment-attempt data later.

---

## Analytics Dashboard

The dashboard should aggregate expenses by:

- Month
- Day
- Category
- Merchant
- Budget progress
- Payment count
- Grouped transactions
- Spending trends

### Example Mobile Summary

```text
Good morning, User 👋

September spending

          ₹12,450
        of ₹20,000

███████████████░░░

Food           ₹3,200
Transport      ₹2,100
Shopping       ₹1,900

Recent

LOLOO STORE            ₹300
Food                   ₹450
Transport              ₹180
```

### Desktop Dashboard

```text
+----------------------------------------------------------------+
| HULY.PAY                                      User            |
+-----------+----------------------------------------------------+
| Overview  | September 2026                                   |
| Expenses  |                                                    |
| Analytics | ₹12,450 spent              ₹20,000 target         |
| Budget    | █████████████░░░                                 |
| Merchants |                                                    |
| Settings  | Category Breakdown                                |
|           |                                                    |
|           | Food        ███████████                           |
|           | Transport   ███████                               |
|           | Shopping    █████                                 |
|           |                                                    |
|           | Spending Trend                                    |
|           |        ╭──╮                                      |
|           |    ╭───╯  ╰────╮                                 |
|           | ───╯            ╰──                              |
+-----------+----------------------------------------------------+
```

### Recommended Analytics APIs

```http
GET /api/v1/analytics/monthly
GET /api/v1/analytics/categories
GET /api/v1/analytics/daily
GET /api/v1/analytics/merchants
GET /api/v1/analytics/budget
```

The backend should return aggregated data rather than sending the entire transaction history to the client for every dashboard render.

---

## Authentication

Supported sign-in methods:

- Email / password
- Google SSO
- GitHub OAuth

A practical implementation is to use an authentication provider such as Firebase Authentication and let the Spring Boot API validate the resulting identity token.

```text
Google / GitHub / Email
          |
          v
   Authentication Layer
          |
          v
       Flutter
          |
          v
   Bearer ID Token
          |
          v
 Spring Boot Authentication Middleware
          |
          v
       users table
```

The backend should use an internal UUID for the user rather than relying on the email address as the primary key.

---

## Google Maps and Places

Google Maps / Places can be used to enrich expense records with merchant information.

Potential merchant fields include:

```text
google_place_id
name
formatted address
location
rating
google maps URI
```

The mobile UI can show a merchant card and allow the user to open the merchant's location in Google Maps.

### API Key Strategy

Use platform-specific restricted API keys for Android, iOS, and Web. Never ship an unrestricted server credential inside the Flutter application.

---

## Local Storage and Cache

SQLite / Drift should be used for:

- Recent expenses
- Merchant information
- Categories
- Dashboard summaries
- User preferences
- Last known analytics

Architecture:

```text
                 PostgreSQL
                     ^
                     |
                 Spring API
                     ^
                     |
                 Flutter App
                /          \
               v            v
         Remote Source    SQLite Cache
```

The API remains the source of truth.

When there is no network connection, Huly.Pay can display cached information and synchronize when connectivity is restored.

---

## Security

All API communication should use HTTPS.

The authenticated user should always be derived from the access token, not from a user-controlled query parameter.

Avoid this pattern:

```http
GET /expenses?userId=123
```

Prefer:

```http
GET /expenses
Authorization: Bearer <token>
```

The backend derives the user identity from the verified token.

### Payment Idempotency

Payment creation endpoints should accept an idempotency key or equivalent unique transaction request identifier.

Without idempotency:

```text
Network retry
     |
     +--> Payment Attempt A
     |
     +--> Payment Attempt B
```

With idempotency:

```text
Same request key
       |
       v
Same payment attempt returned
```

This is particularly important when mobile connectivity is unreliable.

---

## API Design

Initial REST endpoints:

```http
# Authentication / User
GET    /api/v1/auth/me
GET    /api/v1/users/me
PUT    /api/v1/users/me/preferences

# Merchant / QR
POST   /api/v1/merchants/resolve

# Payments
POST   /api/v1/payments/create
GET    /api/v1/payments/{id}
GET    /api/v1/payments/{id}/status

# Expenses
GET    /api/v1/expenses
GET    /api/v1/expenses/{id}
PUT    /api/v1/expenses/{id}
POST   /api/v1/expenses/group

# Categories
GET    /api/v1/categories

# Budget
GET    /api/v1/budget
PUT    /api/v1/budget
GET    /api/v1/budget/summary

# Analytics
GET    /api/v1/analytics/monthly
GET    /api/v1/analytics/category
GET    /api/v1/analytics/trend
GET    /api/v1/analytics/merchants
```

---

## Project Structure

A monorepo is recommended for the first version.

```text
HulyPay/
│
├── mobile/
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
│
├── web-dashboard/
│   ├── lib/
│   └── pubspec.yaml
│
├── backend/
│   ├── src/main/java/com/hulypay/
│   └── src/main/resources/
│       ├── application.yml
│       └── db/migration/
│
├── infrastructure/
│   ├── docker/
│   ├── nginx/
│   └── postgres/
│
└── docs/
    ├── architecture.md
    ├── payment-flow.md
    └── database.md
```

---

## Deployment

### Initial Hosting Plan

```text
                         Internet
                            |
             +--------------+--------------+
             |                             |
             v                             v
          Vercel                     Hostinger DNS
             |                             |
             v                             |
    Flutter Web Dashboard                  |
             |                             |
             +--------------+--------------+
                            |
                           HTTPS
                            |
                            v
                    Spring Boot API
                            |
                 +----------+----------+
                 |                     |
                 v                     v
       Supabase PostgreSQL       Google / UPI APIs
          (Free tier)
```

### Supabase

Supabase is the PostgreSQL layer for the project. It will hold the authoritative application data: users, merchants, payment attempts, expenses, categories, budgets, and analytics source data.

The Flutter clients must not receive database credentials. Mobile and web clients communicate with the Spring Boot API, and the backend communicates with Supabase/PostgreSQL.

### Vercel

Vercel is the initial hosting target for the Flutter Web dashboard. The dashboard is a client application that calls the Spring Boot API over HTTPS. Vercel is not the application's source-of-truth database.

### Hostinger

Hostinger is intended primarily for the project domain/DNS and can also be used for a separate marketing/landing website. A suggested domain layout is:

```text
app.hulypay.com   -> Vercel -> Flutter Web Dashboard
api.hulypay.com   -> Spring Boot Backend
www.hulypay.com   -> Hostinger/static landing page (optional)
```

The backend hosting provider can be changed independently later.


A practical first production setup can look like:

```text
                         Internet
                            |
                            v
                       Cloudflare
                            |
                            v
                       Load Balancer
                            |
                            v
                          Nginx
                            |
             +--------------+--------------+
             |                             |
             v                             v
        Spring Boot                    Flutter Web
             |
       +-----+------+
       |            |
       v            v
 PostgreSQL       Redis
```

An AWS implementation could use:

- ECS or EC2 for Spring Boot
- RDS PostgreSQL
- ElastiCache Redis
- S3 for static/object storage
- CloudFront for CDN delivery
- GitHub Actions for CI/CD

Kubernetes is not required for the initial release.

---

## MVP Roadmap

### Phase 1 — Core Payment Experience

```text
Authentication
   ↓
Home
   ↓
Scan UPI QR
   ↓
Resolve Merchant
   ↓
Enter Amount
   ↓
Create Pending Payment
   ↓
Launch GPay / UPI App
   ↓
Receive Result
   ↓
Verify / Reconcile
   ↓
Save Expense
```

### Phase 2 — Personal Finance

- Expense history
- Categories
- Monthly target
- Spending limit
- Category charts
- Daily / monthly trends
- Merchant history

### Phase 3 — Local-first Experience

- SQLite / Drift cache
- Offline dashboard
- Sync engine
- Local preferences
- Better retry handling

### Phase 4 — Merchant Intelligence

- Google Places enrichment
- Merchant profiles
- Merchant spending history
- Merchant location card
- Maps integration

### Phase 5 — Smart Grouping and Insights

- Group payments at the same merchant
- Monthly insights
- Budget warnings
- Subscription detection
- Spending patterns

### Phase 6 — Web Dashboard

- Full desktop analytics
- Interactive charts
- Merchant analysis
- Budget management
- Expense filtering
- Account settings

### Phase 7 — UI Polish

- Modern Material 3 design system
- Theme switching
- Smooth transitions
- Hero animations
- Micro-interactions
- Accessible loading / empty / error states

---

## Important Design Decisions

### 1. Huly.Pay does not hold user money

The actual UPI payment remains between the user, UPI/payment application, PSP/bank, and merchant. Huly.Pay is the expense and payment-context layer.

### 2. PostgreSQL is the source of truth

SQLite exists for cache/offline UX, not authoritative payment records.

### 3. Do not delete pending transactions immediately

Use `EXPIRED` and a retention policy so delayed reconciliation remains possible.

### 4. Never overwrite raw payment information

Keep payment data and user-editable expense metadata separate.

Example:

```text
payment_attempt
  requested_amount = ₹300
  merchant_vpa = merchant@bank
  transaction_ref = HULY123
  provider_response = {...}
  status = SUCCESS

expense
  amount = ₹300
  category = FOOD
  note = Candy
```

A user can change the category or note without changing the original payment record.

### 5. Category suggestions should be editable

The system can suggest a category using MCC, merchant type, and location, but the user should remain able to change it.

### 6. Keep the first backend simple

A modular monolith is preferred over microservices until real scale requires service separation.

### 7. Treat the payment result as untrusted until verified

Client-side payment responses should enter the backend verification/reconciliation workflow before a payment is considered authoritative.

---

## Example Payment Flow

```text
User scans QR
      |
      v
QR parser
      |
      +--> VPA
      +--> merchant name
      +--> MCC
      +--> optional transaction data
      |
      v
Location service
      |
      v
Google Places / Merchant resolver
      |
      v
Merchant context
      |
      v
POST /api/v1/payments/create
      |
      v
Payment Attempt:
      PENDING
      |
      +--> requested_amount = 300
      +--> expires_at = +30 minutes
      +--> transaction_ref = HULY-...
      |
      v
Flutter launches UPI application
      |
      v
Google Pay / UPI
      |
      v
Bank / UPI network
      |
      v
Result returned to Huly.Pay
      |
      v
Backend reconciliation
      |
      +------------+-------------+
      |            |             |
      v            v             v
   SUCCESS       FAILED       UNKNOWN
      |                         |
      v                         v
Create expense        Reconciliation required
      |
      v
Update dashboard
```

---

## UI Direction

Huly.Pay should feel:

```text
Modern
Minimal
Financial
Fast
Premium
Confident
```

Recommended design principles:

- Material 3 foundation
- Strong typography hierarchy
- Large readable spending totals
- Clear category visualization
- Subtle motion instead of excessive animation
- Fast payment confirmation path
- Accessible loading, error, and empty states
- Consistent design system across mobile and web

The payment experience should prioritize **trust and clarity over visual noise**.

---

## Long-Term Vision

The long-term goal is to make Huly.Pay an intelligent financial layer around everyday UPI activity:

```text
Scan
  ↓
Understand merchant
  ↓
Pay using normal UPI flow
  ↓
Verify transaction
  ↓
Automatically record expense
  ↓
Understand spending
  ↓
Set budgets
  ↓
Detect patterns
  ↓
Give useful insights
```

Huly.Pay should make the user feel that expense tracking happens naturally as a part of paying, rather than being a separate task they have to remember later.
