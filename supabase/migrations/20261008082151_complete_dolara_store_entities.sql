/*
# Complete Chez Dolara commerce entities

1. New Tables
- `promotions`: optional dated product offers and discount metadata.
- `addresses`: reusable delivery address records attached to a checkout customer.
- `favorites`: anonymous browser favorite references, keyed by a browser token.

2. Security
- RLS is enabled on all tables.
- Promotions are publicly readable when active and within their date window.
- Anonymous favorites and addresses can be created during checkout; customer management remains admin-only.
- Authenticated admin sessions manage promotions and all records.
*/

CREATE TABLE IF NOT EXISTS promotions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  name text NOT NULL,
  sale_price numeric(10,2) NOT NULL CHECK (sale_price >= 0),
  starts_at timestamptz NOT NULL,
  ends_at timestamptz,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS addresses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  governorate text NOT NULL,
  city text NOT NULL,
  address_line text NOT NULL,
  postal_code text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS favorites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  browser_token text NOT NULL,
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(browser_token, product_id)
);

CREATE INDEX IF NOT EXISTS promotions_product_id_idx ON promotions(product_id);
CREATE INDEX IF NOT EXISTS favorites_browser_token_idx ON favorites(browser_token);

ALTER TABLE promotions ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can read current promotions" ON promotions;
CREATE POLICY "Public can read current promotions" ON promotions FOR SELECT TO anon, authenticated USING (is_active = true AND starts_at <= now() AND (ends_at IS NULL OR ends_at >= now()));
DROP POLICY IF EXISTS "Admins can insert promotions" ON promotions;
CREATE POLICY "Admins can insert promotions" ON promotions FOR INSERT TO authenticated WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can update promotions" ON promotions;
CREATE POLICY "Admins can update promotions" ON promotions FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can delete promotions" ON promotions;
CREATE POLICY "Admins can delete promotions" ON promotions FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

DROP POLICY IF EXISTS "Public can create addresses" ON addresses;
CREATE POLICY "Public can create addresses" ON addresses FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can read addresses" ON addresses;
CREATE POLICY "Admins can read addresses" ON addresses FOR SELECT TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can update addresses" ON addresses;
CREATE POLICY "Admins can update addresses" ON addresses FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can delete addresses" ON addresses;
CREATE POLICY "Admins can delete addresses" ON addresses FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

DROP POLICY IF EXISTS "Public can read own browser favorites" ON favorites;
CREATE POLICY "Public can read own browser favorites" ON favorites FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "Public can create browser favorites" ON favorites;
CREATE POLICY "Public can create browser favorites" ON favorites FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Public can delete browser favorites" ON favorites;
CREATE POLICY "Public can delete browser favorites" ON favorites FOR DELETE TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "Admins can update favorites" ON favorites;
CREATE POLICY "Admins can update favorites" ON favorites FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
