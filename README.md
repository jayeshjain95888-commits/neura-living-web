# Neura Living | Unified Space Operating System

> One app to run every kind of rented space in India: **Hostels/PGs, Hotels, and Apartments**, with role-based access for owners, staff, residents, and hotel guests.

![Neura Living](https://img.shields.io/badge/Architecture-Modular%20Monolith-blue)
![Theme](https://img.shields.io/badge/UI-Minimal%20Liquid%20Glass-slate)
![Region](https://img.shields.io/badge/Launch%20Market-Jaipur%2C%20India-emerald)
![Database](https://img.shields.io/badge/Backend-Supabase%20PostgreSQL-3ECF8E)
![Payments](https://img.shields.io/badge/Payments-Razorpay%20UPI%20%26%20Cards-0284c7)

---

## 🌟 Key Capabilities

1. **Owner Master Console**: Consolidated multi-property portfolio view across Jaipur (PGs, Hotels, Apartments) in one revenue dashboard.
2. **Strict Role-Based Authentication & Gating**:
   - **Super Admin & Owners:** Authenticate with unique Platform IDs / Passwords.
   - **Staff & Students (Warden, Receptionist, Cleaner, Resident):** Authenticate with **Property Code** (`PG-SHREERAM-101`, `HT-RAJPUTANA-201`, `APT-ROYAL-301`) + **Mobile Number** + **Mobile OTP**.
   - **Hotel Guests (QR Page):** Instant web access (`/h/{code}`) with mobile OTP verification — zero app installation required.
3. **Hostel / PG Module**:
   - Interactive live bed map (Occupied, Vacant, Notice, Reserved).
   - Advance deposit refund ledger with itemized deduction calculator (exit damages & unpaid dues).
   - Automated dues generation & WhatsApp reminder triggers.
   - Weekly mess food menu planner & student maintenance ticketing.
4. **Hotel PMS Module**:
   - Color-coded room status board (Vacant Clean, Occupied, Dirty, Cleaning).
   - Walk-in check-in with masked ID capture (Aadhaar / Passport for Form C / DPDP compliance).
   - GST tax invoice generator with 6% CGST + 6% SGST computation.
   - Housekeeping cleaning task dispatcher.
5. **Apartment Portfolio Module**:
   - Per-flat profit & maintenance tracker.
   - 30/60-day lease renewal warnings with WhatsApp reminder dispatch.
6. **Hotel QR Guest Web Page (`/h/jaipur-grand`)**:
   - Direct online room booking.
   - In-room service & food ordering with live status updates.
   - Razorpay payment checkout integration.

---

## 🛠️ Tech Stack & Integrations

- **Frontend:** HTML5, Modern ES6+ JavaScript, Tailwind CSS (Liquid Glass Styling), Lucide Icons.
- **Database:** Supabase (PostgreSQL 15) with Row Level Security (RLS) policies. Schema located at `schema.sql`.
- **Payments:** Razorpay Checkout (UPI, Cards, NetBanking, and simulated sandbox test hooks).
- **Design Philosophy:** Minimalist liquid glass finish with neutral zinc/slate/stone color grading, subtle specular borders, and high contrast typography.

---

## 🚀 Running Locally

The project includes a self-contained local web server:

```powershell
# In PowerShell:
powershell.exe -ExecutionPolicy Bypass -File "server.ps1"
```
Then browse to: **`http://localhost:3000`**

---

## 🗄️ Supabase Database Setup

1. Create a project at [supabase.com](https://supabase.com).
2. Open the **SQL Editor** in your Supabase dashboard.
3. Paste the contents of [`schema.sql`](./schema.sql) and click **Run**.
4. Copy your `Project URL` and `Anon Key` and configure them in the **Connectors** modal in the app.

---

## 💳 Razorpay Setup

1. Generate your test API Keys from the [Razorpay Dashboard](https://dashboard.razorpay.com).
2. Enter your `RAZORPAY_KEY_ID` in the Connectors modal.
3. Set your webhook endpoint to `https://your-domain/api/payments/webhook` listening for `payment.captured`.

