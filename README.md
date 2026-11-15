# Neura Living | Unified Space Operating System

> **One app to run every kind of rented space in India:** Hostels/PGs, Boutique Hotels, and Rental Apartments — with dedicated, role-gated experiences for everyone who touches the property.

[![Architecture](https://img.shields.io/badge/Architecture-Modular%20Monolith-334155?style=flat-square)](#system-architecture)
[![UI Theme](https://img.shields.io/badge/UI-Plain%20Liquid%20Glass-64748b?style=flat-square)](#design-system--color-grading)
[![Launch Market](https://img.shields.io/badge/Launch%20Market-Jaipur%2C%20India-059669?style=flat-square)](#launch-market--business-model)
[![Database](https://img.shields.io/badge/Backend-Supabase%20PostgreSQL%2015-3ECF8E?style=flat-square&logo=supabase)](#supabase-database-schema)
[![Payments](https://img.shields.io/badge/Payments-Razorpay%20UPI%20%26%20Cards-0284c7?style=flat-square&logo=razorpay)](#razorpay-payments-integration)
[![Status](https://img.shields.io/badge/Status-Interactive%20Prototype%20v1.0-blue?style=flat-square)](#quick-start--local-server)

---

## 📖 Executive Summary & Problem Solved

Every small and mid-size property owner in India faces one shared daily struggle:  
> *"I can't see my money, my staff, or my occupancy without physically being on site."*

Specialist tools cater only to single verticals (PG-only or hotel-only). **Neura Living** unites mixed portfolios under **one owner login and one consolidated revenue dashboard**, while providing role-gated operational interfaces for staff and instant QR mobile web portals for hotel guests.

---

## 🔐 Authentication & Access Architecture

All surfaces are strictly protected by a multi-tiered authentication gate:

| Persona | Authentication Mechanism | Credentials / Access Requirements |
|---|---|---|
| **🛡️ Platform Super Admin** | **Platform Admin ID** + **Password** | ID: `admin@neuraliving.com`<br>Pass: `SuperAdmin@Jaipur99` |
| **👑 Property Owner** | **Owner ID / Email / Phone** + **Password** | ID: `owner@shreeram.com`<br>Pass: `OwnerPass@2026` |
| **👮 PG Warden** | **Property Code** + **Phone** + **Mobile OTP** | Code: `PG-SHREERAM-101`<br>Phone: `98290 12345` • OTP: `7941` |
| **🛎️ Hotel Receptionist** | **Property Code** + **Phone** + **Mobile OTP** | Code: `HT-RAJPUTANA-201`<br>Phone: `94140 88210` • OTP: `5512` |
| **🧹 Housekeeping Cleaner** | **Property Code** + **Phone** + **Mobile OTP** | Code: `HT-RAJPUTANA-201`<br>Phone: `98281 99012` • OTP: `3890` |
| **🎓 Student / PG Member** | **Hostel Code** + **Phone** + **Mobile OTP** | Code: `PG-SHREERAM-101`<br>Phone: `98290 88990` • OTP: `4102` |
| **📱 Hotel Guest (QR Web)** | **Hotel QR Code** (`/h/{code}`) + **Mobile OTP** | Zero app installation required. Verified by OTP for booking & billing. |

---

## 🖥️ Surfaces & Interactive Panels Built

### 1. 🌐 Public Product Landing Page
- **Hero & Value Proposition:** Built for Indian property operators (onboarding in under 30 minutes with CSV migration).
- **Segment Comparison Grid (PRD §1):** Contrasts daily pains with Neura Living solutions across PGs, Hotels, and Flats.
- **SaaS Pricing Model (PRD §12):**
  - **Starter:** ₹49/unit/mo (for small PGs & guest houses).
  - **Growth:** ₹39/unit/mo (most popular for mixed multi-property operators).
  - **Pro Hotel:** ₹59/room/mo (includes direct online booking & GST invoicing).

### 2. 🛡️ Super Admin Console (Platform HQ)
- **Jaipur Pilot Key Metrics (PRD §2):** Tracks 112 paying properties against the 100+ goal, Monthly Recurring Revenue (MRR of ₹2,84,600), 5,840 units under management, and a 1.8% logo churn rate (beating the <4% target).
- **Tenant Directory:** Comprehensive organization table with active plans, unit volumes, and an **Impersonate** session launcher.
- **Assisted Migration Queue (PRD §5.1 CP-9):** Review and 1-click import paper registers and Excel sheets.

### 3. 👑 Owner Master Console
- **Consolidated Financials:** Portfolio occupancy (88.4%), total collections (₹4,82,500), outstanding dues (₹68,200), and net profit.
- **Portfolio Overview:** One-click drill down into individual assets:
  - *Shree Ram PG & Hostel (120 Beds)*
  - *The Grand Rajputana Hotel (24 Rooms)*
  - *Civil Lines Royal Heights (18 Flats)*
- **Bulk WhatsApp Reminders:** Automated reminder dispatch simulator with direct UPI links.
- **Append-Only Audit Ledger:** Complete financial tracking of payment captures and deposit refunds.

### 4. 🛏️ Hostel / PG Module
- **Live Interactive Bed Map:** Filter beds by *All*, *Occupied*, *Vacant*, *Notice Period*, and *Reserved*.
- **Advance Deposit Refund Ledger (PRD PG-4 & 6.5):** Interactive exit calculator that computes itemized deductions (damage fees + unpaid rent) and issues net refund receipts.
- **Mess Menu Manager (PRD PG-10):** Daily breakfast, lunch, snacks, and dinner meal schedule.
- **Student Complaint Ticketing (PRD PG-11):** Open, In Progress, and Resolved maintenance tracking with resolution timers.

### 5. 🏨 Hotel PMS Module
- **Live Room Board Calendar:** Visual statuses for 24 rooms (*Vacant Clean Ready*, *Occupied*, *Dirty Needs Cleaning*, *Cleaning in Progress*).
- **Front Desk Check-In Modal:** Guest record capture with masked ID verification (Aadhaar / Passport for Form C & DPDP compliance).
- **GST Tax Invoicing Generator (PRD HT-5):** Computes room tariff, food extras, 6% CGST, and 6% SGST, generating downloadable tax invoices.

### 6. 🏢 Apartment / Rental Module
- **Per-Flat Profitability Ledger:** Unit-level net profit, deposit balances, and society maintenance charges.
- **Lease Renewal & Vacancy Alerts:** 30/60-day expiry warning triggers with 1-click renewal agreement draft dispatch.

### 7. 📱 Hotel QR Guest Portal (`/h/jaipur-grand`)
- **Zero App Install Required:** Runs directly in any mobile or desktop web browser.
- **Toggle Mobile Frame:** Switch between a simulated mobile device frame and a full desktop view.
- **Direct Room Booking:** Select check-in/out dates and complete payments without OTA commissions.
- **In-Room Amenities & Services:** Order extra towels, drinking water, or meals directly to Room 204.
- **Integrated Razorpay Checkout:** Instant bill payment via UPI, cards, and net banking.

### 8. 👥 Role-Based Staff & Student Portals
- **👮 Warden Desk:** Night curfew attendance register (Present / Night Pass / Late) and cash rent collection logging.
- **🛎️ Front Desk Receptionist:** Expected arrivals/departures and shift cash drawer balance.
- **🧹 Housekeeping Console:** Mobile room task list with 1-click *"Mark Clean & Ready"*.
- **🎓 Student Portal:** Bed view, fee balance, and direct UPI pay button.

---

## 🎨 Design System & Color Grading

- **Plain Liquid Glass Finish:** Specular highlights (`rgba(255, 255, 255, 0.85)`), layered backdrop blur (`backdrop-filter: blur(20px)`), and soft ambient shadows.
- **Color Grading Palette:**
  - Base: Soft stone, alabaster, and oyster tones (`#f8fafc`, `#f1f5f9`).
  - Text & Accents: High-contrast ink slate (`#0f172a`), emerald (`#065f46`), amber (`#92400e`), and sky blue (`#075985`).
  - Typography: **Plus Jakarta Sans** for UI and **JetBrains Mono** for property codes and financial figures.
- **Bilingual Interface:** Instant **English / हिंदी** toggle (PRD CP-10 & QR-8).

---

## 🗄️ Supabase Database Schema

The repository includes a production-grade PostgreSQL migration file: [`schema.sql`](./schema.sql).

### Key Tables Implemented:
1. `organizations` – Multi-tenant owner accounts and SaaS subscription plans.
2. `properties` – Multi-property records (PG, Hotel, Apartment) with public codes.
3. `units` – Generic unit schema covering beds, hotel rooms, and rental flats.
4. `profiles` & `memberships` – Role-Based Access Control (RBAC) linking users to properties.
5. `customers` – Residents, hotel guests, and tenants with DPDP-compliant masked ID proofs.
6. `unit_assignments` – Occupancy contracts and advance deposit tracking.
7. `bookings` – Hotel reservations with date ranges and guest counts.
8. `charges` & `payments` – Append-only financial ledger with Razorpay references.
9. `tasks` – Housekeeping and maintenance dispatch queue.
10. `tickets` – Resident and guest service requests with SLA status.
11. `expenses` – Categorized property operational expenditures.
12. `menu_items` – Weekly hostel mess schedule.

Row-Level Security (RLS) policies are included to enforce tenant isolation and permit public guest reads for QR booking pages.

---

## 💳 Razorpay Payments Integration

- **Order Creation & Verification:** Built-in hooks for Razorpay Checkout (`https://checkout.razorpay.com/v1/checkout.js`).
- **Interactive Sandbox Simulator:** Test UPI QR code generation, PhonePe, Google Pay, and card payments.
- **Webhook Simulator:** Test `payment.captured` and `refund.processed` webhook payloads directly from the **Connectors** modal.

---

## 🚀 Quick Start & Local Server

### Option 1: Native Local Server (Port 3000)
Run the self-contained PowerShell server (no Node.js or Python required):

```powershell
powershell.exe -ExecutionPolicy Bypass -File "server.ps1"
```
Open **[http://localhost:3000](http://localhost:3000)** in your browser.

### Option 2: Direct File Open
You can also open [`index.html`](./index.html) directly in any modern browser (Chrome, Edge, Opera, Safari).

---

## 📁 Repository Structure

```
neura-living-web/
├── index.html                # Complete single-page application (All panels & login gates)
├── preview.html              # Mirror build for instant local previews
├── server.ps1                # Lightweight native PowerShell HTTP server
├── schema.sql                # Complete Supabase PostgreSQL schema with RLS policies
├── package.json              # Project metadata & npm dependency manifest
├── README.md                 # Project documentation & architecture overview
└── .gitignore                # Git ignore configuration
```

---

## 🗺️ Roadmap & Upcoming Refinements

- [x] Multi-property portfolio switcher (PG + Hotel + Apartment).
- [x] Role-gated login architecture (Owner ID vs. Property Code + Phone OTP).
- [x] Liquid glass aesthetic with subtle color grading.
- [x] Live bed map, room board, and exit deposit calculator.
- [x] Hotel QR guest portal with mobile frame toggle.
- [x] Supabase schema & Razorpay connector modal.
- [ ] Live Supabase client auto-syncing with cloud tables.
- [ ] SMS / WhatsApp Business API sandbox integration.
- [ ] Real-time WebSocket notifications for room cleanups and guest requests.
