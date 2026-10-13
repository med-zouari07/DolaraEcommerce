/*
# Connect the live storefront to catalog and orders

1. New database objects
- `dolara_order_number_seq`: sequence used to create unique customer-facing order numbers.
- `create_public_order`: server-side checkout function that creates the customer, order, and order items together.

2. Modified behavior
- Public checkout no longer needs direct table inserts from the browser.
- The function looks up product names and prices from the catalog, verifies requested sizes and stock, calculates the total, and decreases inventory atomically.
- Existing products, customers, orders, and order items are preserved.

3. Security
- Anonymous and authenticated callers may execute only the validated checkout function.
- Direct anonymous inserts into customers, orders, and order_items are revoked; the function performs the writes with its controlled server-side logic.
- The function has a fixed search path and exposes only the resulting order number.

4. Important notes
- The storefront must call `create_public_order` for checkout.
- No payment provider is introduced; orders remain cash-on-delivery requests.
*/

CREATE SEQUENCE IF NOT EXISTS public.dolara_order_number_seq START WITH 1001;

CREATE OR REPLACE FUNCTION public.create_public_order(
  p_customer jsonb,
  p_delivery jsonb,
  p_items jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_customer_id uuid;
  v_order_id uuid;
  v_order_number text;
  v_subtotal numeric(10,2) := 0;
  v_item jsonb;
  v_product products%ROWTYPE;
  v_size product_sizes%ROWTYPE;
  v_quantity integer;
  v_unit_price numeric(10,2);
  v_line_total numeric(10,2);
BEGIN
  IF jsonb_typeof(p_items) <> 'array' OR jsonb_array_length(p_items) = 0 THEN
    RAISE EXCEPTION 'Checkout requires at least one item';
  END IF;

  IF coalesce(trim(p_customer ->> 'first_name'), '') = ''
    OR coalesce(trim(p_customer ->> 'last_name'), '') = ''
    OR coalesce(trim(p_customer ->> 'phone'), '') = ''
    OR coalesce(trim(p_delivery ->> 'governorate'), '') = ''
    OR coalesce(trim(p_delivery ->> 'city'), '') = ''
    OR coalesce(trim(p_delivery ->> 'address'), '') = '' THEN
    RAISE EXCEPTION 'Checkout contact and delivery details are required';
  END IF;

  INSERT INTO customers (first_name, last_name, phone, email)
  VALUES (
    trim(p_customer ->> 'first_name'),
    trim(p_customer ->> 'last_name'),
    trim(p_customer ->> 'phone'),
    nullif(trim(p_customer ->> 'email'), '')
  )
  RETURNING id INTO v_customer_id;

  v_order_number := 'DOL-' || to_char(now(), 'YYMMDD') || '-' || lpad(nextval('public.dolara_order_number_seq')::text, 4, '0');

  INSERT INTO orders (
    order_number, customer_id, delivery_governorate, delivery_city,
    delivery_address, customer_note, subtotal, shipping_fee, total
  )
  VALUES (
    v_order_number,
    v_customer_id,
    trim(p_delivery ->> 'governorate'),
    trim(p_delivery ->> 'city'),
    trim(p_delivery ->> 'address'),
    nullif(trim(p_delivery ->> 'note'), ''),
    0, 0, 0
  )
  RETURNING id INTO v_order_id;

  FOR v_item IN SELECT value FROM jsonb_array_elements(p_items)
  LOOP
    v_quantity := (v_item ->> 'quantity')::integer;
    IF v_quantity IS NULL OR v_quantity < 1 OR v_quantity > 20 THEN
      RAISE EXCEPTION 'Invalid item quantity';
    END IF;

    SELECT * INTO v_product
    FROM products
    WHERE id = (v_item ->> 'product_id')::uuid
      AND is_active = true
    FOR UPDATE;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Product unavailable';
    END IF;

    SELECT * INTO v_size
    FROM product_sizes
    WHERE product_id = v_product.id
      AND lower(size) = lower(trim(v_item ->> 'size'))
    FOR UPDATE;

    IF NOT FOUND OR v_size.stock < v_quantity THEN
      RAISE EXCEPTION 'Requested size is unavailable';
    END IF;

    v_unit_price := v_product.price;
    v_line_total := round(v_unit_price * v_quantity, 2);
    v_subtotal := v_subtotal + v_line_total;

    UPDATE product_sizes
    SET stock = stock - v_quantity
    WHERE id = v_size.id;

    INSERT INTO order_items (
      order_id, product_id, product_name, sku, selected_size,
      quantity, unit_price, line_total
    )
    VALUES (
      v_order_id, v_product.id, v_product.name, v_product.sku,
      trim(v_item ->> 'size'), v_quantity, v_unit_price, v_line_total
    );
  END LOOP;

  UPDATE orders
  SET subtotal = v_subtotal, total = v_subtotal, updated_at = now()
  WHERE id = v_order_id;

  RETURN jsonb_build_object('order_id', v_order_id, 'order_number', v_order_number);
EXCEPTION
  WHEN others THEN
    RAISE EXCEPTION 'Unable to create order';
END;
$$;

REVOKE EXECUTE ON FUNCTION public.create_public_order(jsonb, jsonb, jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.create_public_order(jsonb, jsonb, jsonb) TO anon, authenticated;

REVOKE INSERT ON public.customers FROM anon, authenticated;
REVOKE INSERT ON public.orders FROM anon, authenticated;
REVOKE INSERT ON public.order_items FROM anon, authenticated;