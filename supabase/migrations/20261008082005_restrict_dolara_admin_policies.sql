/*
# Restrict catalog management to admin sessions

1. Security changes
- Authenticated users can no longer manage Chez Dolara catalog, customers, orders, or settings by default.
- Management policies now require the immutable `raw_app_meta_data.role` claim to equal `admin`.
- Public catalog reads and checkout order creation remain available as before.

2. Important note
- The administrator account must be assigned the `admin` role in Supabase Auth app metadata before using the management area.
*/

DROP POLICY IF EXISTS "Admins can insert categories" ON categories;
CREATE POLICY "Admins can insert categories" ON categories FOR INSERT TO authenticated WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can update categories" ON categories;
CREATE POLICY "Admins can update categories" ON categories FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can delete categories" ON categories;
CREATE POLICY "Admins can delete categories" ON categories FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

DROP POLICY IF EXISTS "Admins can insert products" ON products;
CREATE POLICY "Admins can insert products" ON products FOR INSERT TO authenticated WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can update products" ON products;
CREATE POLICY "Admins can update products" ON products FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can delete products" ON products;
CREATE POLICY "Admins can delete products" ON products FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

DROP POLICY IF EXISTS "Admins can insert sizes" ON product_sizes;
CREATE POLICY "Admins can insert sizes" ON product_sizes FOR INSERT TO authenticated WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can update sizes" ON product_sizes;
CREATE POLICY "Admins can update sizes" ON product_sizes FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can delete sizes" ON product_sizes;
CREATE POLICY "Admins can delete sizes" ON product_sizes FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

DROP POLICY IF EXISTS "Admins can insert product images" ON product_images;
CREATE POLICY "Admins can insert product images" ON product_images FOR INSERT TO authenticated WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can update product images" ON product_images;
CREATE POLICY "Admins can update product images" ON product_images FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can delete product images" ON product_images;
CREATE POLICY "Admins can delete product images" ON product_images FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

DROP POLICY IF EXISTS "Customers are readable by admins" ON customers;
CREATE POLICY "Customers are readable by admins" ON customers FOR SELECT TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can update customers" ON customers;
CREATE POLICY "Admins can update customers" ON customers FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can delete customers" ON customers;
CREATE POLICY "Admins can delete customers" ON customers FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

DROP POLICY IF EXISTS "Admins can read orders" ON orders;
CREATE POLICY "Admins can read orders" ON orders FOR SELECT TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can update orders" ON orders;
CREATE POLICY "Admins can update orders" ON orders FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can delete orders" ON orders;
CREATE POLICY "Admins can delete orders" ON orders FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

DROP POLICY IF EXISTS "Admins can read order items" ON order_items;
CREATE POLICY "Admins can read order items" ON order_items FOR SELECT TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can update order items" ON order_items;
CREATE POLICY "Admins can update order items" ON order_items FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can delete order items" ON order_items;
CREATE POLICY "Admins can delete order items" ON order_items FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

DROP POLICY IF EXISTS "Admins can insert store settings" ON store_settings;
CREATE POLICY "Admins can insert store settings" ON store_settings FOR INSERT TO authenticated WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can update store settings" ON store_settings;
CREATE POLICY "Admins can update store settings" ON store_settings FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
DROP POLICY IF EXISTS "Admins can delete store settings" ON store_settings;
CREATE POLICY "Admins can delete store settings" ON store_settings FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
