-- ============================================================
-- IMPORTPORTALEN — Supabase Schema
-- Kjør denne filen i Supabase SQL Editor
-- ============================================================

-- Aktiver UUID-generering
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- PRODUKTER
-- ============================================================
CREATE TABLE products (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL DEFAULT auth.uid(),
    producer TEXT NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('vin', 'brennevin')),
    alcohol_percent NUMERIC(5,2) NOT NULL CHECK (alcohol_percent > 0),
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Brukere ser egne produkter"
    ON products FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Brukere oppretter egne produkter"
    ON products FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Brukere oppdaterer egne produkter"
    ON products FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Brukere sletter egne produkter"
    ON products FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================
-- VAREMOTTAK
-- ============================================================
CREATE TABLE receivings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL DEFAULT auth.uid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price_per_bottle NUMERIC(10,2) NOT NULL CHECK (price_per_bottle >= 0),
    date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE receivings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Brukere ser egne mottak"
    ON receivings FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Brukere oppretter egne mottak"
    ON receivings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Brukere oppdaterer egne mottak"
    ON receivings FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Brukere sletter egne mottak"
    ON receivings FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================
-- KUNDER
-- ============================================================
CREATE TABLE customers (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL DEFAULT auth.uid(),
    name TEXT NOT NULL,
    contact_person TEXT,
    phone TEXT,
    email TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Brukere ser egne kunder"
    ON customers FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Brukere oppretter egne kunder"
    ON customers FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Brukere oppdaterer egne kunder"
    ON customers FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Brukere sletter egne kunder"
    ON customers FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================
-- SALG
-- ============================================================
CREATE TABLE sales (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL DEFAULT auth.uid(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE sales ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Brukere ser egne salg"
    ON sales FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Brukere oppretter egne salg"
    ON sales FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Brukere oppdaterer egne salg"
    ON sales FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Brukere sletter egne salg"
    ON sales FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================
-- INDEKSER for ytelse
-- ============================================================
CREATE INDEX idx_products_user ON products(user_id);
CREATE INDEX idx_receivings_user ON receivings(user_id);
CREATE INDEX idx_receivings_product ON receivings(product_id);
CREATE INDEX idx_receivings_date ON receivings(date);
CREATE INDEX idx_sales_user ON sales(user_id);
CREATE INDEX idx_sales_product ON sales(product_id);
CREATE INDEX idx_sales_customer ON sales(customer_id);
CREATE INDEX idx_sales_date ON sales(date);
CREATE INDEX idx_customers_user ON customers(user_id);
