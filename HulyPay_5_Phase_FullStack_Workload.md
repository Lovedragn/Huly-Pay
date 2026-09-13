# Huly.Pay — 5-Phase Full-Stack Implementation Workload

## Purpose

This document is the implementation workload for **Antigravity**. Implement and connect the existing Flutter mobile application, Spring Boot backend, PostgreSQL database, Supabase Auth, Google Maps/Street View, UPI/Google Pay flow, and React dashboard where present.

## Critical Architecture Rules

- Flutter and React must **not connect directly to PostgreSQL**. All application data goes through Spring Boot REST APIs.
- Supabase is the identity provider/session manager. Spring Boot validates Supabase JWTs and owns application authorization/business logic.
- Do not create another authentication server.
- Local development uses PostgreSQL 17 in Docker with Hibernate `ddl-auto=update`.
- Production uses Supabase PostgreSQL with `ddl-auto=validate`.
- **Do not add Flyway or Liquibase.**
- Use **one `application.yml` only**. Environment-specific values come from environment variables.
- Never commit secrets.

### Google Maps design change

Google Maps is **not** required to identify or verify the merchant during payment. When the user pays a shop using QR:

```text
QR scan → capture current GPS → payment → reconcile/confirm → save transaction + location
                                                              ↓
                                                   Transaction Details
                                                              ↓
                                                  Google Map + marker
                                                        ↙         ↘
                                                 Street View      Start Route
```

The saved latitude/longitude is the payment location. Do not require Google Places merchant matching for the normal payment flow.

---

# Phase 1 — Foundation, Authentication & API Connection

## Objective

Make Flutter and Spring Boot communicate securely using Supabase authentication.

### Backend

Implement/verify:

- Spring Boot startup.
- PostgreSQL connection.
- `GET /api/health`.
- `GET /api/health/database`.
- Spring Security.
- Supabase JWT validation.
- Authenticated user extraction from JWT `sub`.
- `GET /api/v1/users/me` user synchronization.
- User isolation.
- Global exception handling.
- Request validation.
- Appropriate CORS for React.

Keep the backend as a modular monolith with separate Controller, Service, Repository, Entity and DTO responsibilities.

### Flutter

Implement/connect:

- `supabase_flutter` for authentication/session management.
- Email/password login.
- Google OAuth through Supabase.
- GitHub OAuth through Supabase.
- Logout/session handling/token refresh.
- Dio API client.
- `Authorization: Bearer <Supabase access token>` on backend requests.
- Auth-aware navigation and API error handling.

### Acceptance criteria

- Login produces a valid Supabase session.
- Flutter calls Spring Boot with the JWT.
- Valid JWT is accepted.
- Missing/invalid JWT returns `401`.
- `/api/v1/users/me` creates/updates the local user.
- User A cannot access User B's data.

---

# Phase 2 — Core Data, QR Payment & Location Capture

## Objective

Build the transaction/expense foundation and capture the location where a QR payment occurs.

### Backend entities

Implement suitable entities/repositories/services/DTOs for:

**User**

```text
id, email, firstName, lastName, avatarUrl, authProvider, providerSubject
```

**Category**

```text
id, userId, name, icon, createdAt, updatedAt
```

**Expense**

```text
id, userId, categoryId, amount, description, expenseDate, createdAt, updatedAt
```

**Payment**

```text
id, userId
merchantName, upiId
amount, currency
paymentMethod, paymentStatus
transactionReference, upiTransactionId
latitude, longitude, locationAccuracyMeters
paymentDate, paymentTime
createdAt, updatedAt
```

Exact names/types may follow the existing codebase while preserving this information.

### Flutter QR/payment flow

Use the existing project architecture and appropriate packages such as:

- `mobile_scanner` for QR scanning.
- `geolocator` for GPS.
- Existing payment integration / `url_launcher` for opening the payment app.

Flow:

```text
Scan QR
 ↓
Parse UPI information
 ↓
Get current GPS location
 ↓
Create pending payment context
 ↓
Open GPay/payment app
 ↓
Return to Huly.Pay
```

Capture location at payment time only. Do not continuously track the user.

Store:

```text
latitude
longitude
accuracyMeters
```

If permission is denied or GPS fails, do not invent coordinates. Handle the state clearly in the UI.

### APIs

Implement suitable authenticated APIs including:

```text
GET    /api/v1/users/me

GET    /api/v1/categories
POST   /api/v1/categories
PUT    /api/v1/categories/{id}
DELETE /api/v1/categories/{id}

GET    /api/v1/expenses
POST   /api/v1/expenses
GET    /api/v1/expenses/{id}
PUT    /api/v1/expenses/{id}
DELETE /api/v1/expenses/{id}

POST   /api/v1/payments
GET    /api/v1/payments
GET    /api/v1/payments/{id}
```

The authenticated user ID must come from the JWT, never from a trusted client-supplied user ID.

### Acceptance criteria

- QR information can be captured.
- Current payment location can be captured.
- Payment records persist through Spring Boot.
- User-owned records are isolated.
- Amount/category validation works.

---

# Phase 3 — Payment Reconciliation, Transaction Details & Google Maps

## Objective

Connect the payment lifecycle to the saved transaction and implement the complete location-based transaction details experience.

### Payment lifecycle

Do not treat merely returning from GPay as proof of payment.

Use an appropriate lifecycle, for example:

```text
PENDING → PAYMENT_INITIATED → CONFIRMED
                         ↘ FAILED / CANCELLED
```

The backend must be the application source of truth for final payment status and should prevent duplicate transaction creation where possible.

### Transaction location

For a confirmed payment, preserve:

```text
latitude
longitude
locationAccuracyMeters
```

This is the location where the payment was made. Google Places merchant matching is not required.

### Transaction Details API

`GET /api/v1/payments/{id}` must return enough data for the Flutter details screen, including:

```json
{
  "id": "uuid",
  "merchantName": "ABC Store",
  "upiId": "abcstore@upi",
  "amount": 250.00,
  "paymentMethod": "GOOGLE_PAY",
  "paymentStatus": "CONFIRMED",
  "transactionReference": "reference",
  "latitude": 13.082680,
  "longitude": 80.270718,
  "locationAccuracyMeters": 8.5,
  "paymentDate": "2026-09-13",
  "paymentTime": "10:42:00"
}
```

### Flutter Transaction Details screen

Implement the previously designed screen with:

- Back button/title.
- Large Google Map card in the top section.
- Marker at the saved payment coordinates.
- **Street View toggle** in the map card.
- **Start Route** button.
- Shop/merchant name.
- Amount.
- Payment status.
- Date and time.
- Payment method such as Google Pay.
- UPI ID/reference where appropriate.

### Google Map

Use `google_maps_flutter`.

The map must display the **saved transaction coordinates**, not depend on a new merchant search.

### Street View

The user can toggle:

```text
MAP ↔ STREET VIEW
```

If Street View imagery is unavailable at that location, show a clear message such as:

> Street View isn't available at this location.

Missing Street View coverage is not a payment error.

### Start Route

`Start Route` should use:

```text
Current user location → saved payment coordinates
```

Prefer opening the user's maps/navigation application for turn-by-turn navigation rather than implementing a complete navigation engine inside Huly.Pay.

### Acceptance criteria

- Transaction details load from Spring Boot.
- Saved coordinates appear on Google Maps.
- Marker is correctly positioned.
- Street View toggle works when imagery exists.
- No-coverage state works.
- Start Route uses the saved payment coordinates.
- Google Places merchant verification is not required for this flow.

---

# Phase 4 — Expenses, Analytics & React Dashboard

## Objective

Expose financial data through backend analytics and connect both Flutter and React to the same APIs.

### Backend analytics

Implement authenticated APIs for:

- Total spending.
- Spending by category.
- Spending by day/week/month.
- Payment count.
- Average transaction amount.
- Recent transactions.
- Top merchants.
- Payment method breakdown.
- Monthly comparisons.

Example:

```text
GET /api/v1/analytics/summary
GET /api/v1/analytics/spending
GET /api/v1/analytics/categories
GET /api/v1/analytics/recent
```

All results must be scoped to the authenticated user.

### Flutter

Connect:

- Transaction history.
- Search/filtering.
- Date/category filters.
- Spending charts.
- Category charts.
- Payment method summaries.
- Transaction details.

Use the project's chosen state management and `fl_chart` where applicable.

### React dashboard

Connect the existing React + TypeScript dashboard to Spring Boot.

It must:

- Authenticate with Supabase.
- Send the Supabase JWT to Spring Boot.
- Fetch transactions/analytics through Spring Boot.
- Display charts and transaction data.
- Respect user isolation.

React must not connect directly to PostgreSQL.

### Acceptance criteria

- Flutter and React show consistent data for the same user.
- Confirmed payments appear in history.
- Analytics include saved transactions.
- User isolation remains enforced.

---

# Phase 5 — Testing, Security, Production Readiness & Final Integration

## Objective

Validate the complete system and prepare it for deployment.

### Backend tests

Test:

**Authentication**

- Public health endpoints.
- Missing JWT → `401`.
- Invalid JWT → `401`.
- Valid JWT → successful authenticated request.
- User synchronization.

**Authorization**

- User isolation.
- Cannot read/update another user's payment.
- Cannot read/update another user's expense.
- Cannot read/update another user's category.

**Validation**

- Invalid amount.
- Zero/negative amount.
- Invalid category.
- Malformed request.
- Invalid coordinates where applicable.

**Payments**

- Pending payment.
- Confirmed payment.
- Failed/cancelled payment.
- Duplicate-payment protection.
- Location persistence.

**Database**

- Repository/integration tests as appropriate.

### Flutter tests

Test:

- Login/logout/session refresh.
- API errors.
- QR scanning.
- Location permission.
- GPS failure/poor accuracy.
- Payment launch/return.
- Transaction persistence.
- Transaction details.
- Map rendering.
- Street View unavailable state.
- Start Route.
- Expense/category flows.
- Analytics.
- Loading/empty/error states.

### Security

Verify:

- No secrets committed.
- JWT required for protected APIs.
- Authorization is based on authenticated identity.
- No server Google Maps key exposed in Flutter.
- Appropriate Google Maps key restrictions.
- Request validation.
- Sensible CORS.
- Production uses `ddl-auto=validate`.
- No Flyway/Liquibase.
- No unnecessary public endpoints.

### Reliability/performance

Only add complexity when justified. Potential later improvements:

- Rate limiting.
- Caching.
- Structured logging.
- Metrics/observability.
- Pagination.
- Performance optimization.

Do not introduce microservices, Kafka, or unnecessary infrastructure.

---

# Required End-to-End Test

Antigravity must verify this complete flow:

```text
1. Open Flutter
2. Sign in through Supabase
3. Receive authenticated session
4. Call Spring Boot with JWT
5. Spring Boot validates JWT
6. Scan a shop QR
7. Parse UPI information
8. Capture current GPS location
9. Pay using GPay/payment app
10. Reconcile/confirm payment
11. Save payment + location through Spring Boot
12. Show transaction in history
13. Open Transaction Details
14. Show saved payment location on Google Maps
15. Toggle Street View
16. Handle Street View unavailable state
17. Tap Start Route
18. Open navigation toward saved payment location
19. Show the same transaction in React dashboard
20. Include transaction in analytics
```

# Global Definition of Done

## Backend

- [ ] Spring Boot starts.
- [ ] PostgreSQL works.
- [ ] Health APIs work.
- [ ] Supabase JWT validation works.
- [ ] User synchronization works.
- [ ] User isolation works.
- [ ] Expense CRUD works.
- [ ] Categories work.
- [ ] Payment records work.
- [ ] Payment status/reconciliation foundation works.
- [ ] Payment location is stored.
- [ ] Transaction details API works.
- [ ] Analytics APIs work.
- [ ] Validation and exception handling work.
- [ ] Tests exist.
- [ ] No Flyway/Liquibase.
- [ ] No secrets committed.
- [ ] Only one `application.yml`.
- [ ] Local PostgreSQL uses `ddl-auto=update`.
- [ ] Production supports `ddl-auto=validate`.

## Flutter

- [ ] Supabase authentication works.
- [ ] JWT is sent to Spring Boot.
- [ ] QR scanner works.
- [ ] GPS capture works.
- [ ] Payment flow works.
- [ ] Payment location is saved.
- [ ] Transaction history works.
- [ ] Transaction details work.
- [ ] Google Map displays saved location.
- [ ] Street View toggle works.
- [ ] Street View unavailable state works.
- [ ] Start Route works.
- [ ] Expenses/categories work.
- [ ] Analytics/charts work.
- [ ] Loading/error/empty states work.

## React Dashboard

- [ ] Supabase authentication works.
- [ ] JWT is sent to Spring Boot.
- [ ] Transactions load.
- [ ] Analytics load.
- [ ] Charts work.
- [ ] User isolation works.

# Instructions to Antigravity

You are not being asked to merely explain the implementation. **Actually inspect, implement, connect, run and test the existing project.**

Before changing anything:

1. Inspect the existing Flutter project.
2. Inspect the existing Spring Boot project.
3. Inspect the existing React dashboard if present.
4. Inspect existing entities, APIs, screens and services.
5. Preserve working code.
6. Reuse the existing architecture where sensible.
7. Do not introduce Flyway or Liquibase.
8. Do not create profile-specific YAML files.
9. Use environment variables for environment-specific configuration.
10. Never hard-code secrets.
11. Fix existing authentication issues before building dependent features.
12. Implement the five phases in order.
13. Do not move forward while the current phase is broken.
14. Run backend tests after backend changes.
15. Run Flutter analyzer/tests after Flutter changes.
16. Run the complete end-to-end flow before declaring completion.
17. Do not replace existing working features without a clear reason.
18. If an existing API/model differs from this document, adapt it consistently rather than creating duplicate implementations.

## Important Maps requirement

The core Maps feature is **payment-location memory**, not merchant verification:

```text
QR payment
   ↓
Capture GPS
   ↓
Save coordinates with transaction
   ↓
Transaction Details
   ↓
Google Map
   ↓
Street View toggle
   ↓
Start Route
```

Google Places merchant matching may be added later as an optional enhancement, but it is not part of the required payment flow.

## Final report required from Antigravity

At the end of every phase report:

1. What was implemented.
2. Files created.
3. Files modified.
4. APIs created/changed.
5. Database entities/tables created/changed.
6. Flutter screens/services changed.
7. Environment variables required.
8. Tests executed.
9. Test results.
10. Remaining manual configuration.
11. Known limitations.

Do not claim a feature is complete unless it has actually been implemented and tested.
