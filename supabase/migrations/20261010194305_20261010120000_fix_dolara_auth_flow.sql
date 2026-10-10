/*
# Fix Dolara administrator authentication

1. Purpose
- Replace manually-created Auth account assumptions with a normal Supabase email/password sign-up flow.
- Centralize the administrator allowlist in one database function used by catalog policies.

2. Modified security behavior
- The following email addresses are recognized as administrators: admin.test@chezdolara.tn, admin@chez-dolara.tn, and admin.nouveau@chez-dolara.tn.
- Public catalog and checkout access remains unchanged.
- No store data is deleted or recreated.

3. Important notes
- The browser must create a new account through Supabase Auth using the Create account screen.
- The administrator function reads the authenticated email claim and does not trust editable user metadata.
*/

CREATE OR REPLACE FUNCTION public.is_dolara_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
  SELECT lower(coalesce(auth.jwt() ->> 'email', '')) IN (
    'admin.test@chezdolara.tn',
    'admin@chez-dolara.tn',
    'admin.nouveau@chez-dolara.tn'
  );
$$;

DROP POLICY IF EXISTS "Admins can insert categories" ON categories;
CREATE POLICY "Admins can insert categories" ON categories FOR INSERT TO authenticated WITH CHECK (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can update categories" ON categories;
CREATE POLICY "Admins can update categories" ON categories FOR UPDATE TO authenticated USING (public.is_dolara_admin()) WITH CHECK (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can delete categories" ON categories;
CREATE POLICY "Admins can delete categories" ON categories FOR DELETE TO authenticated USING (public.is_dolara_admin());

DROP POLICY IF EXISTS "Admins can insert products" ON products;
CREATE POLICY "Admins can insert products" ON products FOR INSERT TO authenticated WITH CHECK (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can update products" ON products;
CREATE POLICY "Admins can update products" ON products FOR UPDATE TO authenticated USING (public.is_dolara_admin()) WITH CHECK (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can delete products" ON products;
CREATE POLICY "Admins can delete products" ON products FOR DELETE TO authenticated USING (public.is_dolara_admin());

DROP POLICY IF EXISTS "Admins can insert sizes" ON product_sizes;
CREATE POLICY "Admins can insert sizes" ON product_sizes FOR INSERT TO authenticated WITH CHECK (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can update sizes" ON product_sizes;
CREATE POLICY "Admins can update sizes" ON product_sizes FOR UPDATE TO authenticated USING (public.is_dolara_admin()) WITH CHECK (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can delete sizes" ON product_sizes;
CREATE POLICY "Admins can delete sizes" ON product_sizes FOR DELETE TO authenticated USING (public.is_dolara_admin());

DROP POLICY IF EXISTS "Admins can insert product images" ON product_images;
CREATE POLICY "Admins can insert product images" ON product_images FOR INSERT TO authenticated WITH CHECK (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can update product images" ON product_images;
CREATE POLICY "Admins can update products images" ON product_images FOR UPDATE TO authenticated USING (public.is_dolara_admin()) WITH CHECK (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can delete product images" ON product_images;
CREATE POLICY "Admins can delete product images" ON product_images FOR DELETE TO authenticated USING (public.is_dolara_admin());

DROP POLICY IF EXISTS "Customers are readable by admins" ON customers;
CREATE POLICY "Customers are readable by admins" ON customers FOR SELECT TO authenticated USING (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can update customers" ON customers;
CREATE POLICY "Admins can update customers" ON customers FOR UPDATE TO authenticated USING (public.is_dolara_admin()) WITH CHECK (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can delete customers" ON customers;
CREATE POLICY "Admins can delete customers" ON customers FOR DELETE TO authenticated USING (public.is_dolara_admin());

DROP POLICY IF EXISTS "Admins can read orders" ON orders;
CREATE POLICY "Admins can read orders" ON orders FOR SELECT TO authenticated USING (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can update orders" ON orders;
CREATE POLICY "Admins can update orders" ON orders FOR UPDATE TO authenticated USING (public.is_dolara_admin()) WITH CHECK (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can delete orders" ON orders;
CREATE POLICY "Admins can delete orders" ON orders FOR DELETE TO authenticated USING (public.is_dolara_admin());

DROP POLICY IF EXISTS "Admins can read order items" ON order_items;
CREATE POLICY "Admins can read order items" ON order_items FOR SELECT TO authenticated USING (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can update order items" ON order_items;
CREATE POLICY "Admins can update order items" ON order_items FOR UPDATE TO authenticated USING (public.is_dolara_admin()) WITH CHECK (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can delete order items" ON order_items;
CREATE POLICY "Admins can delete order items" ON order_items FOR DELETE TO authenticated USING (public.is_dolara_admin());

DROP POLICY IF EXISTS "Admins can insert store settings" ON store_settings;
CREATE POLICY "Admins can insert store settings" ON store_settings FOR INSERT TO authenticated WITH CHECK (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can update store settings" ON store_settings;
CREATE POLICY "Admins can update store settings" ON store_settings FOR UPDATE TO authenticated USING (public.is_dolara_admin()) WITH CHECK (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can delete store settings" ON store_settings;
CREATE POLICY "Admins can delete store settings" ON store_settings FOR DELETE TO authenticated USING (public.is_dolara_admin());

DROP POLICY IF EXISTS "Admins can insert promotions" ON promotions;
CREATE POLICY "Admins can insert promotions" ON promotions FOR INSERT TO authenticated WITH CHECK (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can update promotions" ON promotions;
CREATE POLICY "Admins can update promotions" ON promotions FOR UPDATE TO authenticated USING (public.is_dolara_admin()) WITH CHECK (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can delete promotions" ON promotions;
CREATE POLICY "Admins can delete promotions" ON promotions FOR DELETE TO authenticated USING (public.is_dolara_admin());

DROP POLICY IF EXISTS "Admins can read addresses" ON addresses;
CREATE POLICY "Admins can read addresses" ON addresses FOR SELECT TO authenticated USING (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can update addresses" ON addresses;
CREATE POLICY "Admins can update addresses" ON addresses FOR UPDATE TO authenticated USING (public.is_dolara_admin()) WITH CHECK (public.is_dolara_admin());
DROP POLICY IF EXISTS "Admins can delete addresses" ON addresses;
CREATE POLICY "Admins can delete addresses" ON addresses FOR DELETE TO authenticated USING (public.is_dolara_admin());

DROP POLICY IF EXISTS "Admins can update favorites" ON favorites;
CREATE POLICY "Admins can update favorites" ON favorites FOR UPDATE TO authenticated USING (public.is_dolara_admin()) WITH CHECK (public.is_dolara_admin());

REVOKE EXECUTE ON FUNCTION public.is_dolara_admin() FROM anon;
REVOKE EXECUTE ON FUNCTION public.is_dolara_admin() FROM authenticated;
GRANT EXECUTE ON FUNCTION public.is_dolara_admin() TO authenticated;
