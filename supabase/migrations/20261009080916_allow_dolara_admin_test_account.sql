/*
# Allow the Dolara administrator test account

1. Security changes
- Adds one explicit, fixed administrator test email to the existing admin access checks.
- Keeps all catalog, customer, order, and settings writes restricted to authenticated sessions.
- The test account still must authenticate through Supabase email/password.

2. Important notes
- The test account is intended to unblock the first admin setup when the original manually provisioned Auth user has invalid credentials.
- No password is stored in this migration.
*/

DROP POLICY IF EXISTS "Admins can insert categories" ON categories;
CREATE POLICY "Admins can insert categories" ON categories FOR INSERT TO authenticated WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can update categories" ON categories;
CREATE POLICY "Admins can update categories" ON categories FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can delete categories" ON categories;
CREATE POLICY "Admins can delete categories" ON categories FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');

DROP POLICY IF EXISTS "Admins can insert products" ON products;
CREATE POLICY "Admins can insert products" ON products FOR INSERT TO authenticated WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can update products" ON products;
CREATE POLICY "Admins can update products" ON products FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can delete products" ON products;
CREATE POLICY "Admins can delete products" ON products FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');

DROP POLICY IF EXISTS "Admins can insert sizes" ON product_sizes;
CREATE POLICY "Admins can insert sizes" ON product_sizes FOR INSERT TO authenticated WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can update sizes" ON product_sizes;
CREATE POLICY "Admins can update sizes" ON product_sizes FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can delete sizes" ON product_sizes;
CREATE POLICY "Admins can delete sizes" ON product_sizes FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');

DROP POLICY IF EXISTS "Admins can insert product images" ON product_images;
CREATE POLICY "Admins can insert product images" ON product_images FOR INSERT TO authenticated WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can update product images" ON product_images;
CREATE POLICY "Admins can update product images" ON product_images FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can delete product images" ON product_images;
CREATE POLICY "Admins can delete product images" ON product_images FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');

DROP POLICY IF EXISTS "Customers are readable by admins" ON customers;
CREATE POLICY "Customers are readable by admins" ON customers FOR SELECT TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can update customers" ON customers;
CREATE POLICY "Admins can update customers" ON customers FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can delete customers" ON customers;
CREATE POLICY "Admins can delete customers" ON customers FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');

DROP POLICY IF EXISTS "Admins can read orders" ON orders;
CREATE POLICY "Admins can read orders" ON orders FOR SELECT TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can update orders" ON orders;
CREATE POLICY "Admins can update orders" ON orders FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can delete orders" ON orders;
CREATE POLICY "Admins can delete orders" ON orders FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');

DROP POLICY IF EXISTS "Admins can read order items" ON order_items;
CREATE POLICY "Admins can read order items" ON order_items FOR SELECT TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can update order items" ON order_items;
CREATE POLICY "Admins can update order items" ON order_items FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can delete order items" ON order_items;
CREATE POLICY "Admins can delete order items" ON order_items FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');

DROP POLICY IF EXISTS "Admins can insert promotions" ON promotions;
CREATE POLICY "Admins can insert promotions" ON promotions FOR INSERT TO authenticated WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can update promotions" ON promotions;
CREATE POLICY "Admins can update promotions" ON promotions FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can delete promotions" ON promotions;
CREATE POLICY "Admins can delete promotions" ON promotions FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');

DROP POLICY IF EXISTS "Admins can insert store settings" ON store_settings;
CREATE POLICY "Admins can insert store settings" ON store_settings FOR INSERT TO authenticated WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can update store settings" ON store_settings;
CREATE POLICY "Admins can update store settings" ON store_settings FOR UPDATE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn') WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
DROP POLICY IF EXISTS "Admins can delete store settings" ON store_settings;
CREATE POLICY "Admins can delete store settings" ON store_settings FOR DELETE TO authenticated USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin' OR lower(auth.jwt() ->> 'email') = 'admin.test@chezdolara.tn');
