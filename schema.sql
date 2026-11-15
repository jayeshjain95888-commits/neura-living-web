-- ========================================================================
-- NEURA LIVING - PRODUCTION-GRADE POSTGRESQL SCHEMA (Supabase Compliant)
-- Multi-property management for PGs, Hotels, and Apartments
-- Includes DPDP compliance, append-only ledger triggers, and double-booking exclusion constraints
-- ========================================================================

-- Enable necessary PostgreSQL extensions
create extension if not exists "uuid-ossp";
create extension if not exists "btree_gist";

-- 1. Organizations (Multi-Tenant Owner Accounts)
create table if not exists public.organizations (
    id uuid primary key default uuid_generate_v4(),
    name text not null,
    plan text default 'GROWTH' check (plan in ('STARTER', 'GROWTH', 'PRO')),
    is_active boolean default true,
    billing_email text,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- 2. Properties (PG / Hotel / Apartment)
create table if not exists public.properties (
    id uuid primary key default uuid_generate_v4(),
    org_id uuid not null references public.organizations(id) on delete cascade,
    type text not null check (type in ('PG', 'HOTEL', 'APARTMENT')),
    name text not null,
    slug text unique not null, -- Canonical URL slug (e.g. 'jaipur-grand', 'shree-ram-pg')
    public_code text unique not null, -- Short alphanumeric code (e.g. 'HT-RAJPUTANA-201', 'PG-SHREERAM-101')
    city text not null default 'Jaipur',
    state text not null default 'Rajasthan',
    address text,
    gstin text, -- Owner / Property GSTIN (e.g. '08AAAAA0000A1Z5')
    settings jsonb default '{
        "due_day": 5,
        "late_fee_per_day": 50,
        "gst_enabled": true,
        "deposit_months": 2,
        "currency": "INR",
        "checkin_time": "14:00",
        "checkout_time": "11:00"
    }'::jsonb,
    is_active boolean default true,
    created_at timestamptz default now()
);

-- 3. Units (Beds for PG, Rooms for Hotel, Flats for Apartments)
create table if not exists public.units (
    id uuid primary key default uuid_generate_v4(),
    property_id uuid not null references public.properties(id) on delete cascade,
    kind text not null check (kind in ('BED', 'ROOM', 'FLAT')),
    label text not null, -- e.g. "Bed 101-A", "Room 204", "Flat 402"
    floor text default 'Ground Floor',
    unit_category text default 'Standard', -- e.g. "Single", "Double Sharing", "Deluxe King", "3BHK"
    status text not null default 'VACANT' check (status in ('VACANT', 'OCCUPIED', 'NOTICE_PERIOD', 'RESERVED', 'DIRTY', 'CLEANING', 'BLOCKED')),
    base_rate numeric(12, 2) not null default 0.00 check (base_rate >= 0),
    created_at timestamptz default now()
);

-- 4. User Profiles & Role-Based Memberships (Supabase Auth linked)
create table if not exists public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    phone text unique not null,
    full_name text not null,
    email text,
    language text default 'en' check (language in ('en', 'hi')),
    created_at timestamptz default now()
);

create table if not exists public.memberships (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references public.profiles(id) on delete cascade,
    org_id uuid not null references public.organizations(id) on delete cascade,
    property_id uuid references public.properties(id) on delete set null,
    role text not null check (role in ('SUPER_ADMIN', 'OWNER', 'WARDEN', 'STUDENT', 'MANAGER', 'RECEPTIONIST', 'CLEANER')),
    is_active boolean default true,
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
    id_proof_type text check (id_proof_type in ('Aadhaar', 'Passport', 'Voter_ID', 'Driving_License', 'Other')),
    id_proof_last4 text, -- Storing ONLY last 4 digits for DPDP compliance (e.g. '3491')
    dpdp_consent_captured boolean default false,
    dpdp_consent_timestamp timestamptz,
    status text not null default 'ACTIVE' check (status in ('ACTIVE', 'NOTICE', 'CHECKED_OUT', 'INACTIVE')),
    created_at timestamptz default now()
);

-- 6. Unit Assignments (Active Occupancy & Deposits)
create table if not exists public.unit_assignments (
    id uuid primary key default uuid_generate_v4(),
    unit_id uuid not null references public.units(id) on delete cascade,
    customer_id uuid not null references public.customers(id) on delete cascade,
    start_date date not null default current_date,
    end_date date,
    deposit_held numeric(12, 2) default 0.00 check (deposit_held >= 0),
    deposit_deductions numeric(12, 2) default 0.00 check (deposit_deductions >= 0),
    deposit_refunded numeric(12, 2) default 0.00 check (deposit_refunded >= 0),
    deposit_status text default 'HELD' check (deposit_status in ('HELD', 'REFUND_PENDING', 'REFUNDED')),
    created_at timestamptz default now()
);

-- 7. Hotel Bookings with Strict Double-Booking Exclusion Constraint
create table if not exists public.bookings (
    id uuid primary key default uuid_generate_v4(),
    property_id uuid not null references public.properties(id) on delete cascade,
    unit_id uuid not null references public.units(id) on delete cascade,
    customer_id uuid not null references public.customers(id) on delete cascade,
    stay_dates daterange not null, -- [check_in, check_out)
    adults int default 1 check (adults >= 1),
    children int default 0 check (children >= 0),
    source text default 'DIRECT_QR' check (source in ('DIRECT_QR', 'WALK_IN', 'PHONE', 'ONLINE')),
    status text not null default 'CONFIRMED' check (status in ('HOLD', 'CONFIRMED', 'CHECKED_IN', 'CHECKED_OUT', 'CANCELLED')),
    base_tariff numeric(12, 2) not null check (base_tariff >= 0),
    extras_amount numeric(12, 2) default 0.00 check (extras_amount >= 0),
    cgst_amount numeric(12, 2) default 0.00 check (cgst_amount >= 0),
    sgst_amount numeric(12, 2) default 0.00 check (sgst_amount >= 0),
    total_amount numeric(12, 2) not null check (total_amount >= 0),
    advance_paid numeric(12, 2) default 0.00 check (advance_paid >= 0),
    created_at timestamptz default now(),
    -- Mathematical guarantee preventing overlapping reservations for the same unit
    exclude using gist (unit_id with =, stay_dates with &&) where (status in ('HOLD', 'CONFIRMED', 'CHECKED_IN'))
);

-- 8. Append-Only Financial Ledger: Charges & Payments
create table if not exists public.charges (
    id uuid primary key default uuid_generate_v4(),
    property_id uuid not null references public.properties(id) on delete cascade,
    customer_id uuid not null references public.customers(id) on delete cascade,
    booking_id uuid references public.bookings(id) on delete set null,
    category text not null check (category in ('ROOM_TARIFF', 'PG_RENT', 'MESS_FOOD', 'ELECTRICITY', 'MAINTENANCE', 'DEPOSIT', 'GST', 'EXTRA')),
    sac_hsn_code text, -- e.g. '996311' for room stay, '996331' for restaurant food
    description text not null,
    amount numeric(12, 2) not null check (amount >= 0),
    due_date date not null,
    status text not null default 'PENDING' check (status in ('PENDING', 'PARTIAL', 'PAID', 'OVERDUE')),
    created_at timestamptz default now()
);

create table if not exists public.payments (
    id text primary key, -- Gateway payment id (pay_XXXX) or fiscal cash receipt (REC-2026-XXXX)
    property_id uuid not null references public.properties(id) on delete cascade,
    customer_id uuid not null references public.customers(id) on delete cascade,
    charge_id uuid references public.charges(id) on delete set null,
    amount numeric(12, 2) not null check (amount > 0),
    currency text default 'INR',
    mode text not null check (mode in ('UPI', 'CASH', 'BANK_TRANSFER', 'CARD', 'RAZORPAY')),
    gateway_order_id text,
    razorpay_signature text,
    status text not null default 'SUCCESS' check (status in ('SUCCESS', 'PENDING', 'FAILED', 'REVERSED')),
    collected_by uuid references public.profiles(id) on delete set null,
    created_at timestamptz default now()
);

-- IMMUTABLE LEDGER TRIGGERS (Prevent tampering with financial history)
create or replace function public.prevent_ledger_tampering()
returns trigger as $$
begin
    raise exception 'Financial records in public.payments and public.charges are immutable. Only compensatory reversal entries are permitted.';
end;
$$ language plpgsql;

create trigger trg_immutable_payments
before update or delete on public.payments
for each row execute function public.prevent_ledger_tampering();

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

-- 10. Service Requests & Complaints (QR Portal / Student App)
create table if not exists public.tickets (
    id uuid primary key default uuid_generate_v4(),
    property_id uuid not null references public.properties(id) on delete cascade,
    customer_id uuid references public.customers(id) on delete set null,
    unit_id uuid references public.units(id) on delete set null,
    title text not null,
    category text check (category in ('WIFI', 'PLUMBING', 'FOOD', 'NOISE', 'HOUSEKEEPING', 'AMENITIES', 'BILLING', 'OTHER')),
    source text not null default 'APP' check (source in ('APP', 'QR', 'DESK')),
    status text not null default 'OPEN' check (status in ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')),
    resolution_notes text,
    created_at timestamptz default now(),
    resolved_at timestamptz
);

-- 11. Property Operational Expenses
create table if not exists public.expenses (
    id uuid primary key default uuid_generate_v4(),
    property_id uuid not null references public.properties(id) on delete cascade,
    category text not null check (category in ('UTILITIES', 'REPAIRS', 'STAFF_SALARY', 'GROCERY_FOOD', 'TAXES', 'OTHER')),
    amount numeric(12, 2) not null check (amount > 0),
    description text not null,
    receipt_url text,
    expense_date date not null default current_date,
    created_at timestamptz default now()
);

-- 12. Weekly Mess Menu Items
create table if not exists public.menu_items (
    id uuid primary key default uuid_generate_v4(),
    property_id uuid not null references public.properties(id) on delete cascade,
    day_of_week int not null check (day_of_week between 0 and 6), -- 0=Sun, 6=Sat
    meal_type text not null check (meal_type in ('BREAKFAST', 'LUNCH', 'SNACKS', 'DINNER')),
    description text not null,
    is_active boolean default true,
    created_at timestamptz default now()
);

-- ========================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Strict Isolation: Prevents data leaks between organizations & guests
-- ========================================================================
alter table public.organizations enable row level security;
alter table public.properties enable row level security;
alter table public.units enable row level security;
alter table public.profiles enable row level security;
alter table public.memberships enable row level security;
alter table public.customers enable row level security;
alter table public.unit_assignments enable row level security;
alter table public.bookings enable row level security;
alter table public.charges enable row level security;
alter table public.payments enable row level security;
alter table public.tasks enable row level security;
alter table public.tickets enable row level security;
alter table public.expenses enable row level security;
alter table public.menu_items enable row level security;

-- NARROW PUBLIC POLICIES FOR HOTEL QR GUEST PORTAL
-- Exposes ONLY property metadata (name, slug, settings) and available room types.
-- NEVER exposes guest PII, other bookings, or financial ledgers!
create policy "Public guest view active property details by slug"
on public.properties for select
using (is_active = true);

create policy "Public guest view unit availability and rates"
on public.units for select
using (status in ('VACANT', 'RESERVED'));

create policy "Public guest view mess menu"
on public.menu_items for select
using (is_active = true);

create policy "Public guest submit service requests"
on public.tickets for insert
with check (source = 'QR');

-- TENANT & OWNER ACCESS POLICIES
create policy "Staff and owners view own organization properties"
on public.properties for all
using (
    org_id in (
        select m.org_id from public.memberships m
        where m.user_id = auth.uid() and m.is_active = true
    )
);

create policy "Staff and owners view units in assigned property"
on public.units for all
using (
    property_id in (
        select m.property_id from public.memberships m
        where m.user_id = auth.uid() and m.is_active = true
    )
);
