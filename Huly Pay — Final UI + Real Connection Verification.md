# Huly Pay — Final UI and End-to-End Connection Task

The attached screenshots represent the **current final UI design** for Huly Pay.

Treat these screens as the visual baseline. **Do not redesign the UI unnecessarily.**

The charts/analytics data shown in the screenshots are currently placeholders and can be replaced later. The priority now is to make sure that **all functional connections work according to the Huly Pay workflow and architecture.**

---

## 1. Final Screens to Preserve

The current application contains these major screens:

1. Login / Welcome Back
2. Home Dashboard
3. Spending Insights / Analyze
4. Transactions
5. Transaction Details
6. QR Scanner
7. Profile & Settings

Preserve the existing visual design, spacing, navigation, typography, dark OLED theme, buttons, cards, icons, and overall layout unless a change is required to make functionality work.

---

# 2. Authentication Workflow

The login screen contains:

- Google
- GitHub
- Continue with Email
- Sign Up

### Google Sign-In

Verify the complete flow:

Flutter Login
→ Google Sign-In
→ Google Account Selection
→ Google Authentication
→ Flutter receives authenticated account/token
→ Backend authentication endpoint
→ Backend validates authentication
→ User is found or created in database
→ Authenticated session/token returned
→ Flutter stores session
→ Home Dashboard

Do not consider Google Sign-In successful merely because the Google account picker opens.

The test must confirm that:

- Google account can be selected.
- Authentication succeeds.
- Flutter receives the authentication result.
- Backend receives the required credential/token.
- Backend accepts and validates it.
- User is created/found correctly.
- The authenticated user reaches Home.
- User-specific data is associated with the correct account.

---

# 3. Login Persistence

After successful login:

App
→ authenticated session
→ close/restart application
→ session restored
→ user remains logged in

Verify that authentication state is not lost unexpectedly.

---

# 4. Logout Workflow

Profile & Settings
→ Logout
→ clear local session/token
→ invalidate backend session where applicable
→ Login screen

After logout:

- Protected screens should not remain accessible as an authenticated user.
- Restarting the application should not automatically restore the previous session unless the authentication system intentionally supports it.

---

# 5. Home Dashboard

The Home screen should consume real application data.

Current UI contains:

- User name
- Total Spent
- Spending comparison
- Quick actions
- Spending chart
- Recent Transactions

The chart can remain temporary.

However:

### User information

Login
→ Backend
→ User record
→ Flutter
→ Home

The displayed user must correspond to the authenticated account.

### Total spending

Transaction database
→ Backend aggregation/API
→ Flutter
→ Total Spent

Do not hard-code ₹12,480 once real transaction data is available.

### Recent transactions

Database
→ Backend
→ Flutter
→ Recent Transactions

These must reflect actual transactions.

---

# 6. Analyze / Spending Insights

The current Spending Insights screen contains a category chart.

The chart itself is **replaceable later**.

The important requirement is:

Transactions
→ Backend
→ Category aggregation
→ Flutter
→ Spending Insights

The categories and amounts should eventually come from real transaction data.

For now, do not spend time redesigning the chart.

---

# 7. Transactions Screen

The Transactions screen contains:

- Search
- Category/status filters
- Transaction list
- Date grouping
- Transaction amount
- Merchant name
- Payment status
- Payment category
- Time

Required workflow:

Database
→ Transaction API
→ Flutter
→ Transactions Screen

Verify:

- Transactions are retrieved from backend.
- No permanent demo transactions are used.
- Search works against loaded transaction data.
- Filters work.
- Failed transactions display correctly.
- Dates/times are displayed correctly.
- Amounts are correct.
- Each transaction has a unique ID.

---

# 8. Transaction Details

When the user taps a transaction:

Transactions
→ selected transaction ID
→ Transaction Details API/data
→ Transaction Details Screen

The details screen should show the correct transaction.

Current UI contains:

- Map
- MAP / STREET VIEW toggle
- Start Route
- Payment Successful
- Amount
- Merchant
- Time
- Pay Again
- Share
- Receipt
- Payment Method
- Category
- Transaction Type
- UPI reference information

Verify that these values come from the selected transaction/backend wherever applicable.

Do not use the same hard-coded Swiggy/₹320 transaction for every transaction.

---

# 9. Location / Route Workflow

Transaction Details contains:

Current Location
→ Destination / Merchant Location
→ Map
→ Start Route

When the user presses:

**Start Route**

the application should initiate the route from the user's current location to the transaction/merchant destination.

Verify:

- Location permission.
- Current GPS location.
- Destination coordinates.
- Map initialization.
- Route/navigation action.
- Permission denied handling.
- Location unavailable handling.

Do not fake the current location.

If the application opens an external maps/navigation application, that is acceptable if that is the intended architecture.

---

# 10. Map / Street View Toggle

The Transaction Details map contains:

`MAP | STREET VIEW`

Verify that the toggle actually changes the displayed map mode.

Do not leave the button as a visual-only control.

If Street View requires a separate API/service, verify its configuration and clearly report if an external API key or service is required.

---

# 11. QR Scanner Workflow

The QR Scanner screen contains:

- QR camera
- Demo QR
- Flash
- Camera switch
- Back to Home

Required workflow:

QR Scanner
→ Camera permission
→ Camera
→ QR detection
→ Parse UPI QR
→ Extract payment information
→ Payment flow

Verify that:

- Camera permission works.
- Camera opens.
- QR detection works.
- Invalid QR codes are handled.
- Valid UPI QR data is parsed.
- Parsed merchant/payment information reaches the next payment screen.

Do not treat a static demo QR as the final implementation.

The Demo QR can remain for development testing.

---

# 12. Payment Workflow

The intended payment workflow is:

User
→ Scan UPI QR
→ Parse UPI information
→ Enter/confirm amount
→ Select payment method
→ Initiate payment
→ External UPI/payment application
→ User completes payment
→ Payment result
→ Huly Pay
→ Backend
→ Transaction database
→ Transaction History
→ Transaction Details

Verify every connection that the current implementation actually supports.

### Important

Do not claim that Huly Pay can force another UPI application such as Google Pay to lock an amount unless the actual payment/UPI integration supports that capability.

The application should only claim payment success based on a trustworthy payment result.

---

# 13. Payment Method

The application UI currently shows payment methods such as:

- GPay
- Other configured payment methods

Verify:

Flutter
→ payment method selection
→ correct payment request
→ external payment application
→ payment result

Do not create fake success responses simply to make the UI work.

---

# 14. Backend Architecture

Verify the complete backend path:

Flutter
→ API
→ Spring Boot Controller
→ Service
→ Repository
→ PostgreSQL/Supabase
→ Response
→ Flutter

Check every endpoint used by the application.

For each endpoint verify:

- URL
- HTTP method
- Request
- Authentication
- Authorization
- Controller
- Service
- Repository
- Database operation
- Response
- Error handling

---

# 15. Android Emulator + Local Backend

When running Flutter on an Android Emulator and Spring Boot locally:

Flutter Emulator
→ `10.0.2.2:<SPRING_BOOT_PORT>`
→ Development Computer
→ Spring Boot
→ PostgreSQL/Supabase

Do not use:

`localhost:<port>`

from the Android Emulator to access the development computer.

Also verify:

- Android INTERNET permission
- Network configuration
- Backend port
- Firewall/network access
- HTTP/HTTPS configuration

---

# 16. Database

Verify:

Backend
→ PostgreSQL/Supabase

Check:

- Connection
- Credentials
- Environment variables
- Tables
- Entities
- Relationships
- Repositories
- Transaction persistence
- User persistence

Perform safe read/write tests.

Do not delete production data.

---

# 17. Profile & Settings

The Profile screen contains:

- User profile
- Personal Information
- Payment Methods
- Notifications
- Themes & Skins
- Privacy & Security
- Help & Support
- About HulyPay
- Logout

Verify that navigation from each item works.

Do not leave buttons that appear functional but do nothing, unless they are explicitly marked as coming-soon.

---

# 18. Navigation Verification

Verify the complete navigation graph:

Login
↓
Home
├── Analyze
├── Transactions
│   └── Transaction Details
├── QR Scanner
└── Profile & Settings
    ├── Personal Information
    ├── Payment Methods
    ├── Notifications
    ├── Themes & Skins
    ├── Privacy & Security
    ├── Help & Support
    ├── About HulyPay
    └── Logout

Back buttons must return to the correct previous screen.

Bottom navigation must preserve the correct selected tab.

---

# 19. Demo Data Policy

Identify all demo/static/mock data.

Classify each item:

### Temporary UI data

Examples:

- Chart values
- Placeholder analytics
- Temporary merchant examples

These may remain temporarily.

### Functional data

Examples:

- User
- Transactions
- Payment status
- Payment reference
- Authentication
- Merchant/payment information

These must be connected to the actual backend/data source where the workflow requires it.

Do not replace real functionality with mock data.

---

# 20. End-to-End Test

Perform this complete test:

### Test 1 — Authentication

1. Launch backend.
2. Confirm database connection.
3. Launch Android Emulator.
4. Launch Flutter app.
5. Tap Google.
6. Select Google account.
7. Complete authentication.
8. Confirm backend authentication.
9. Confirm user database record.
10. Reach Home.

### Test 2 — Session

1. Close app.
2. Reopen app.
3. Confirm session behavior.

### Test 3 — QR

1. Open QR Scanner.
2. Grant camera permission.
3. Scan a valid UPI QR.
4. Confirm QR information is parsed.
5. Continue to payment flow.

### Test 4 — Payment

1. Select payment method.
2. Initiate payment.
3. Complete payment if the integration permits testing.
4. Confirm the actual result.
5. Store transaction.

### Test 5 — Transactions

1. Open Transactions.
2. Confirm new transaction appears.
3. Search for it.
4. Apply filters.
5. Open it.

### Test 6 — Transaction Details

1. Confirm merchant.
2. Confirm amount.
3. Confirm date/time.
4. Confirm payment method.
5. Confirm status.
6. Confirm UPI reference where available.
7. Test map.
8. Test Street View.
9. Test Start Route.

### Test 7 — Profile

1. Open Profile.
2. Verify authenticated user's information.
3. Test available settings.
4. Logout.

### Test 8 — Logout

1. Confirm return to Login.
2. Restart application.
3. Confirm correct logged-out behavior.

---

# 21. Final Connection Matrix

Create a report:

| Connection | Status |
|---|---|
| Flutter → Google Sign-In | PASS / FAIL / BLOCKED |
| Google → Flutter | PASS / FAIL / BLOCKED |
| Flutter → Backend | PASS / FAIL / BLOCKED |
| Backend → Database | PASS / FAIL / BLOCKED |
| Authentication → Backend | PASS / FAIL / BLOCKED |
| User → Database | PASS / FAIL / BLOCKED |
| Transaction → Database | PASS / FAIL / BLOCKED |
| Database → Transaction History | PASS / FAIL / BLOCKED |
| Transaction → Details | PASS / FAIL / BLOCKED |
| QR Camera | PASS / FAIL / BLOCKED |
| QR → Payment Flow | PASS / FAIL / BLOCKED |
| Payment → External UPI App | PASS / FAIL / BLOCKED |
| Payment Result → Backend | PASS / FAIL / BLOCKED |
| Location → Current Position | PASS / FAIL / BLOCKED |
| Location → Destination | PASS / FAIL / BLOCKED |
| Map → Route | PASS / FAIL / BLOCKED |
| Street View | PASS / FAIL / BLOCKED |
| Logout → Session Clearing | PASS / FAIL / BLOCKED |

---

# 22. Definition of DONE

The task is NOT complete because the application builds successfully.

The task is complete only when:

- UI remains consistent with the final screens.
- Authentication works.
- Backend connection works.
- Database connection works.
- User data works.
- Transaction data works.
- QR scanning works.
- Payment flow works to the extent supported by the integration.
- Transaction persistence works.
- Transaction history works.
- Transaction details work.
- Location works.
- Route action works.
- Navigation works.
- Logout works.
- Errors are handled.
- Demo data is clearly separated from functional data.

Charts/analytics can be improved later.

---

# Final Report

At the end, provide:

## 1. What is working

List verified connections.

## 2. What is broken

List exact errors.

## 3. What was fixed

List files/components changed.

## 4. What is blocked

Clearly identify missing:

- API keys
- OAuth configuration
- Firebase configuration
- Payment provider configuration
- Environment variables
- External service requirements

## 5. Remaining work

Only list genuinely remaining tasks.

## 6. Final status

Use one of:

`END-TO-END WORKFLOW: PASS`

or

`END-TO-END WORKFLOW: BLOCKED`

Never report PASS without actually testing the connection.