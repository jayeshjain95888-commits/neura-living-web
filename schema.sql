-- ========================================================================
-- NEURA LIVING - SUPABASE POSTGRESQL SCHEMA (PRD Compliant)
-- Multi-property management for PGs, Hotels, and Apartments
-- ========================================================================

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. Organizations (Owner Accounts)
create table if not exists public.organizations (
    id uuid primary key default uuid_generate_v4(),
    name text not null,
    plan text default 'STARTER' check (plan in ('STARTER', 'GROWTH', 'PRO')),
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- 2. Properties (PG / Hotel / Apartment)
create table if not exists public.properties (
    id uuid primary key default uuid_generate_v4(),
    org_id uuid not null references public.organizations(id) on delete cascade,
    type text not null check (type in ('PG', 'HOTEL', 'APARTMENT')),
    name text not null,
    city text not null default 'Jaipur',
    address text,
    public_code text unique, -- Used for Hotel QR code / direct booking link (/h/{code})
    settings jsonb default '{
        "due_day": 5,
        "late_fee_per_day": 50,
        "gst_enabled": true,
        "gst_percentage": 12,
        "deposit_months": 2,
        "currency": "INR"
    }'::jsonb,
    created_at timestamptz default now()
);

-- 3. Units (Beds for PG, Rooms for Hotel, Flats for Apartments)
create table if not exists public.units (
    id uuid primary key default uuid_generate_v4(),
    property_id uuid not null references public.properties(id) on delete cascade,
    kind text not null check (kind in ('BED', 'ROOM', 'FLAT')),
    label text not null, -- e.g. "Bed 101-A", "Room 204", "Flat 402"
    floor text default 'Ground Floor',
    sharing_type text, -- e.g. "Single", "Double Sharing", "Triple Sharing", "Deluxe Room", "3BHK"
    status text not null default 'VACANT' check (status in ('VACANT', 'OCCUPIED', 'NOTICE_PERIOD', 'RESERVED', 'DIRTY', 'CLEANING', 'BLOCKED')),
    base_rate numeric(10, 2) not null default 0.00,
    created_at timestamptz default now()
);

-- 4. User Profiles & Role-Based Memberships
create table if not exists public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    phone text unique not null,
    name text not null,
    language text default 'en' check (language in ('en', 'hi')),
    created_at timestamptz default now()
);

create table if not exists public.memberships (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references public.profiles(id) on delete cascade,
    org_id uuid not null references public.organizations(id) on delete cascade,
    property_id uuid references public.properties(id) on delete set null,
    role text not null check (role in ('OWNER', 'WARDEN', 'STUDENT', 'MANAGER', 'RECEPTIONIST', 'CLEANER')),
    created_at timestamptz default now(),
    unique (user_id, org_id, property_id, role)
);

-- 5. Customers (Members in PG, Guests in Hotel, Tenants in Apartments)
create table if not exists public.customers (
    id uuid primary key default uuid_generate_v4(),
    property_id uuid not null references public.properties(id) on delete cascade,
    type text not null check (type in ('MEMBER', 'GUEST', 'TENANT')),
    name text not null,
    phone text not null,
    email text,
    guardian_name text,
    guardian_phone text,
    id_proof_type text, -- 'Aadhaar', 'Passport', 'Driving License'
    id_proof_masked text, -- Masked for DPDP compliance (e.g. XXXX-XXXX-1234)
    status text not null default 'ACTIVE' check (status in ('ACTIVE', 'NOTICE', 'CHECKED_OUT', 'INACTIVE')),
    created_at timestamptz default now()
);

-- 6. Unit Assignments (Active Occupancy)
create table if not exists public.unit_assignments (
    id uuid primary key default uuid_generate_v4(),
    unit_id uuid not null references public.units(id) on delete cascade,
    customer_id uuid not null references public.customers(id) on delete cascade,
    start_date date not null default current_date,
    end_date date,
    deposit_amount numeric(10, 2) default 0.00,
    deposit_refunded numeric(10, 2) default 0.00,
    deposit_status text default 'HELD' check (deposit_status in ('HELD', 'REFUND_PENDING', 'REFUNDED')),
    created_at timestamptz default now()
);

-- 7. Hotel Bookings
create table if not exists public.bookings (
    id uuid primary key default uuid_generate_v4(),
    property_id uuid not null references public.properties(id) on delete cascade,
    unit_id uuid references public.units(id) on delete set null,
    customer_id uuid references public.customers(id) on delete cascade,
    check_in date not null,
    check_out date not null,
    adults int default 1,
    children int default 0,
    source text default 'DIRECT_QR' check (source in ('DIRECT_QR', 'WALK_IN', 'PHONE', 'ONLINE')),
    status text not null default 'CONFIRMED' check (status in ('HOLD', 'CONFIRMED', 'CHECKED_IN', 'CHECKED_OUT', 'CANCELLED')),
    total_amount numeric(10, 2) not null,
    advance_paid numeric(10, 2) default 0.00,
    created_at timestamptz default now()
);

-- 8. Financial Ledger: Charges & Payments
create table if not exists public.charges (
    id uuid primary key default uuid_generate_v4(),
    property_id uuid not null references public.properties(id) on delete cascade,
    customer_id uuid not null references public.customers(id) on delete cascade,
    category text not null check (category in ('RENT', 'FOOD', 'ELECTRICITY', 'MAINTENANCE', 'DEPOSIT', 'GST', 'EXTRA')),
    description text,
    amount numeric(10, 2) not null,
    due_date date not null,
    status text not null default 'PENDING' check (status in ('PENDING', 'PARTIAL', 'PAID', 'OVERDUE')),
    created_at timestamptz default now()
);

create table if not exists public.payments (
    id text primary key, -- Razorpay Payment ID or custom cash receipt no (e.g. pay_XXXX / CASH_001)
    property_id uuid not null references public.properties(id) on delete cascade,
    customer_id uuid not null references public.customers(id) on delete cascade,
    charge_id uuid references public.charges(id) on delete set null,
    amount numeric(10, 2) not null,
    currency text default 'INR',
    mode text not null check (mode in ('UPI', 'CASH', 'BANK', 'CARD', 'RAZORPAY')),
    gateway_order_id text, -- Razorpay order_id
    status text not null default 'SUCCESS' check (status in ('SUCCESS', 'PENDING', 'FAILED', 'REVERSED')),
    collected_by uuid references public.profiles(id) on delete set null,
    created_at timestamptz default now()
);

-- 9. Housekeeping & Maintenance Tasks
create table if not exists public.tasks (
    id uuid primary key default uuid_generate_v4(),
    property_id uuid not null references public.properties(id) on delete cascade,
    unit_id uuid not null references public.units(id) on delete cascade,
    type text not null check (type in ('CLEANING', 'MAINTENANCE', 'INSPECTION')),
    priority text default 'MEDIUM' check (priority in ('LOW', 'MEDIUM', 'HIGH')),
    status text not null default 'PENDING' check (status in ('PENDING', 'IN_PROGRESS', 'COMPLETED')),
    notes text,
    assigned_to uuid references public.profiles(id) on delete set null,
    created_at timestamptz default now(),
    completed_at timestamptz
);

-- 10. Complaints & Guest Requests (QR / Member Portal)
create table if not exists public.tickets (
    id uuid primary key default uuid_generate_v4(),
    property_id uuid not null references public.properties(id) on delete cascade,
    customer_id uuid references public.customers(id) on delete cascade,
    unit_id uuid references public.units(id) on delete set null,
    title text not null,
    category text check (category in ('WIFI', 'PLUMBING', 'FOOD', 'NOISE', 'HOUSEKEEPING', 'BILLING', 'OTHER')),
    source text not null default 'APP' check (source in ('APP', 'QR', 'DESK')),
    status text not null default 'OPEN' check (status in ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')),
    created_at timestamptz default now()
);

-- 11. Property Expenses
create table if not exists public.expenses (
    id uuid primary key default uuid_generate_v4(),
    property_id uuid not null references public.properties(id) on delete cascade,
    category text not null check (category in ('UTILITIES', 'REPAIRS', 'STAFF_SALARY', 'SUPPLIES', 'TAX', 'OTHER')),
    amount numeric(10, 2) not null,
    description text,
    expense_date date not null default current_date,
    created_at timestamptz default now()
);

-- 12. Weekly Food Menu (Hostels / PGs)
create table if not exists public.menu_items (
    id uuid primary key default uuid_generate_v4(),
    property_id uuid not null references public.properties(id) on delete cascade,
    day_of_week int check (day_of_week between 0 and 6), -- 0=Sun, 6=Sat
    meal_type text check (meal_type in ('BREAKFAST', 'LUNCH', 'SNACKS', 'DINNER')),
    description text not null,
    created_at timestamptz default now()
);

-- ========================================================================
-- Row Level Security (RLS) Enablement
-- ========================================================================
alter table public.organizations enable row level security;
alter table public.properties enable row level security;
alter table public.units enable row level security;
alter table public.customers enable row level security;
alter table public.charges enable row level security;
alter table public.payments enable row level security;
alter table public.tasks enable row level security;
alter table public.tickets enable row level security;

-- Public read access for Hotel Guest QR pages matching property code
create policy "Allow public guest read property by code"
on public.properties for select
using (true);

create policy "Allow public guest read units for booking"
on public.units for select
using (true);

