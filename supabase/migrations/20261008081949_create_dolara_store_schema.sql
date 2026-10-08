/*
# Create Chez Dolara store schema

1. New Tables
- `categories`: public product categories with optional imagery.
- `products`: product catalog, pricing, promotion, and availability.
- `product_sizes`: per-size inventory for each product.
- `product_images`: product gallery images.
- `customers`: checkout customer contact details.
- `orders`: customer orders, delivery details, totals, and status.
- `order_items`: immutable product snapshots captured at order time.
- `store_settings`: public store and delivery configuration.

2. Security
- Row level security is enabled on every table.
- Public visitors can read active catalog data and create orders.
- Only authenticated users can manage catalog, settings, customers, and order statuses.
- Order item snapshots preserve historical data when products change.

3. Notes
- No payment provider is included in this first release.
- The schema is single-tenant for Chez Dolara and does not add customer accounts.
*/

CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  slug text NOT NULL UNIQUE,
  image_url text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  sku text NOT NULL UNIQUE,
  description text NOT NULL DEFAULT '',
  price numeric(10,2) NOT NULL CHECK (price >= 0),
  old_price numeric(10,2) CHECK (old_price IS NULL OR old_price >= price),
  is_active boolean NOT NULL DEFAULT true,
  is_featured boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS product_sizes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  size text NOT NULL,
  stock integer NOT NULL DEFAULT 0 CHECK (stock >= 0),
  UNIQUE(product_id, size)
);

CREATE TABLE IF NOT EXISTS product_images (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  image_url text NOT NULL,
  alt_text text NOT NULL DEFAULT '',
  sort_order integer NOT NULL DEFAULT 0,
  is_primary boolean NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name text NOT NULL,
  last_name text NOT NULL,
  phone text NOT NULL,
  email text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number text NOT NULL UNIQUE,
  customer_id uuid REFERENCES customers(id) ON DELETE SET NULL,
  delivery_governorate text NOT NULL,
  delivery_city text NOT NULL,
  delivery_address text NOT NULL,
  delivery_postal_code text,
  customer_note text,
  subtotal numeric(10,2) NOT NULL CHECK (subtotal >= 0),
  shipping_fee numeric(10,2) NOT NULL DEFAULT 0 CHECK (shipping_fee >= 0),
  total numeric(10,2) NOT NULL CHECK (total >= 0),
  status text NOT NULL DEFAULT 'new' CHECK (status IN ('new','pending','confirmed','preparing','shipped','delivered','cancelled')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id) ON DELETE SET NULL,
  product_name text NOT NULL,
  sku text NOT NULL,
  selected_size text NOT NULL,
  quantity integer NOT NULL CHECK (quantity > 0),
  unit_price numeric(10,2) NOT NULL CHECK (unit_price >= 0),
  line_total numeric(10,2) NOT NULL CHECK (line_total >= 0)
);

CREATE TABLE IF NOT EXISTS store_settings (
  key text PRIMARY KEY,
  value jsonb NOT NULL DEFAULT '{}'::jsonb,
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS products_category_id_idx ON products(category_id);
CREATE INDEX IF NOT EXISTS products_active_created_idx ON products(is_active, created_at DESC);
CREATE INDEX IF NOT EXISTS product_sizes_product_id_idx ON product_sizes(product_id);
CREATE INDEX IF NOT EXISTS orders_status_created_idx ON orders(status, created_at DESC);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_sizes ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can read active categories" ON categories;
CREATE POLICY "Public can read active categories" ON categories FOR SELECT TO anon, authenticated USING (is_active = true OR auth.role() = 'authenticated');
DROP POLICY IF EXISTS "Admins can insert categories" ON categories;
CREATE POLICY "Admins can insert categories" ON categories FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can update categories" ON categories;
CREATE POLICY "Admins can update categories" ON categories FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can delete categories" ON categories;
CREATE POLICY "Admins can delete categories" ON categories FOR DELETE TO authenticated USING (true);

DROP POLICY IF EXISTS "Public can read active products" ON products;
CREATE POLICY "Public can read active products" ON products FOR SELECT TO anon, authenticated USING (is_active = true OR auth.role() = 'authenticated');
DROP POLICY IF EXISTS "Admins can insert products" ON products;
CREATE POLICY "Admins can insert products" ON products FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can update products" ON products;
CREATE POLICY "Admins can update products" ON products FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can delete products" ON products;
CREATE POLICY "Admins can delete products" ON products FOR DELETE TO authenticated USING (true);

DROP POLICY IF EXISTS "Public can read available sizes" ON product_sizes;
CREATE POLICY "Public can read available sizes" ON product_sizes FOR SELECT TO anon, authenticated USING (EXISTS (SELECT 1 FROM products WHERE products.id = product_sizes.product_id AND (products.is_active = true OR auth.role() = 'authenticated')));
DROP POLICY IF EXISTS "Admins can insert sizes" ON product_sizes;
CREATE POLICY "Admins can insert sizes" ON product_sizes FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can update sizes" ON product_sizes;
CREATE POLICY "Admins can update sizes" ON product_sizes FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can delete sizes" ON product_sizes;
CREATE POLICY "Admins can delete sizes" ON product_sizes FOR DELETE TO authenticated USING (true);

DROP POLICY IF EXISTS "Public can read product images" ON product_images;
CREATE POLICY "Public can read product images" ON product_images FOR SELECT TO anon, authenticated USING (EXISTS (SELECT 1 FROM products WHERE products.id = product_images.product_id AND (products.is_active = true OR auth.role() = 'authenticated')));
DROP POLICY IF EXISTS "Admins can insert product images" ON product_images;
CREATE POLICY "Admins can insert product images" ON product_images FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can update product images" ON product_images;
CREATE POLICY "Admins can update product images" ON product_images FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can delete product images" ON product_images;
CREATE POLICY "Admins can delete product images" ON product_images FOR DELETE TO authenticated USING (true);

DROP POLICY IF EXISTS "Customers are readable by admins" ON customers;
CREATE POLICY "Customers are readable by admins" ON customers FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "Public can create customers" ON customers;
CREATE POLICY "Public can create customers" ON customers FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can update customers" ON customers;
CREATE POLICY "Admins can update customers" ON customers FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can delete customers" ON customers;
CREATE POLICY "Admins can delete customers" ON customers FOR DELETE TO authenticated USING (true);

DROP POLICY IF EXISTS "Admins can read orders" ON orders;
CREATE POLICY "Admins can read orders" ON orders FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "Public can create orders" ON orders;
CREATE POLICY "Public can create orders" ON orders FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can update orders" ON orders;
CREATE POLICY "Admins can update orders" ON orders FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can delete orders" ON orders;
CREATE POLICY "Admins can delete orders" ON orders FOR DELETE TO authenticated USING (true);

DROP POLICY IF EXISTS "Admins can read order items" ON order_items;
CREATE POLICY "Admins can read order items" ON order_items FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "Public can create order items" ON order_items;
CREATE POLICY "Public can create order items" ON order_items FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can update order items" ON order_items;
CREATE POLICY "Admins can update order items" ON order_items FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can delete order items" ON order_items;
CREATE POLICY "Admins can delete order items" ON order_items FOR DELETE TO authenticated USING (true);

DROP POLICY IF EXISTS "Public can read store settings" ON store_settings;
CREATE POLICY "Public can read store settings" ON store_settings FOR SELECT TO anon, authenticated USING (key IN ('delivery', 'contact', 'branding'));
DROP POLICY IF EXISTS "Admins can insert store settings" ON store_settings;
CREATE POLICY "Admins can insert store settings" ON store_settings FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can update store settings" ON store_settings;
CREATE POLICY "Admins can update store settings" ON store_settings FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can delete store settings" ON store_settings;
CREATE POLICY "Admins can delete store settings" ON store_settings FOR DELETE TO authenticated USING (true);
