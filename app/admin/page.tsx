'use client';

import './admin.css';
import { BarChart3, Bell, ChevronRight, CircleAlert, LayoutDashboard, LogOut, Package, Plus, Search, Settings, ShoppingBag, Users } from 'lucide-react';
import { useEffect, useState } from 'react';
import { supabase } from '../../lib/supabase/client';

const isDolaraAdmin = (user: { email?: string | null } | null) => ['admin.test@chezdolara.tn', 'admin@chez-dolara.tn', 'admin.nouveau@chez-dolara.tn'].includes(user?.email?.toLowerCase() ?? '');
const sizeOptions = ['XS', 'S', 'M', 'L', 'XL', '36', '38', '40', '42'];

type AdminProduct = {
  id: string;
  name: string;
  sku: string;
  price: number;
  is_active: boolean;
  image_url?: string;
};

type AdminOrder = {
  id: string;
  customer: string;
  date: string;
  amount: string;
  status: string;
};

export default function AdminPage() {
  const [loggedIn, setLoggedIn] = useState(false);
  const [checkingSession, setCheckingSession] = useState(true);
  const [authLoading, setAuthLoading] = useState(false);
  const [authError, setAuthError] = useState('');
  const [createMode, setCreateMode] = useState(true);
  const [email, setEmail] = useState('admin.nouveau@chez-dolara.tn');
  const [password, setPassword] = useState('');
  const [status, setStatus] = useState('Toutes');
  const [activeSection, setActiveSection] = useState('dashboard');
  const [products, setProducts] = useState<AdminProduct[]>([]);
  const [orders, setOrders] = useState<AdminOrder[]>([]);
  const [productModalOpen, setProductModalOpen] = useState(false);
  const [productLoading, setProductLoading] = useState(false);
  const [productError, setProductError] = useState('');
  const [productForm, setProductForm] = useState({ name: '', sku: '', price: '', description: '' });
  const [productImage, setProductImage] = useState<File | null>(null);
  const [sizeStock, setSizeStock] = useState<Record<string, number>>({ S: 0, M: 0, L: 0 });

  useEffect(() => {
    let mounted = true;

    supabase.auth.getSession().then(({ data }) => {
      if (!mounted) return;
      setLoggedIn(isDolaraAdmin(data.session?.user ?? null));
      setCheckingSession(false);
    });

    const { data: listener } = supabase.auth.onAuthStateChange((_event, session) => {
      if (!mounted) return;
      setLoggedIn(isDolaraAdmin(session?.user ?? null));
      setCheckingSession(false);
    });

    return () => {
      mounted = false;
      listener.subscription.unsubscribe();
    };
  }, []);

  const handleLogin = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setAuthLoading(true);
    setAuthError('');
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    const isAdmin = isDolaraAdmin(data.user);
    if (error || !isAdmin) {
      await supabase.auth.signOut();
      setAuthError('Email, mot de passe ou accès administrateur incorrect.');
    } else {
      setLoggedIn(true);
    }
    setAuthLoading(false);
  };

  const handleSignup = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setAuthLoading(true);
    setAuthError('');
    const { data, error } = await supabase.auth.signUp({ email, password });
    if (error) {
      const { data: loginData, error: loginError } = await supabase.auth.signInWithPassword({ email, password });
      const isAdmin = isDolaraAdmin(loginData.user);
      if (!loginError && isAdmin) {
        setLoggedIn(true);
      } else {
        setAuthError(error.message.includes('already registered') || error.message.includes('Database error') ? 'Ce compte existe déjà ou la création est bloquée. Utilisez Connexion avec le même email et mot de passe.' : error.message);
      }
    } else if (isDolaraAdmin(data.user) && data.session) {
      setLoggedIn(true);
    } else if (data.user) {
      setAuthError('Compte créé. Vérifiez votre email si Supabase demande une confirmation, puis connectez-vous.');
    }
    setAuthLoading(false);
  };

  const loadProducts = async () => {
    const { data, error } = await supabase.from('products').select('id, name, sku, price, is_active, product_images(image_url, is_primary, sort_order)').order('created_at', { ascending: false });
    if (error) {
      setProductError('Impossible de charger les produits.');
      return;
    }
    type ProductRow = AdminProduct & { product_images: { image_url: string; is_primary: boolean; sort_order: number }[] };
    setProducts(((data ?? []) as ProductRow[]).map((product) => ({ ...product, image_url: product.product_images?.sort((a, b) => Number(b.is_primary) - Number(a.is_primary) || a.sort_order - b.sort_order)[0]?.image_url })));

  };

  const loadOrders = async () => {
    const { data, error } = await supabase.from('orders').select('id, order_number, total, status, created_at, customers(first_name, last_name)').order('created_at', { ascending: false });
    if (error) {
      console.error('orders load failed', error);
      return;
    }
    type OrderRow = { id: string; order_number: string; total: number; status: string; created_at: string; customers: { first_name: string; last_name: string } | null };
    const statusLabels: Record<string, string> = { new: 'Nouvelle', pending: 'En attente', confirmed: 'Confirmée', preparing: 'En préparation', shipped: 'Expédiée', delivered: 'Livrée', cancelled: 'Annulée' };
    setOrders((data as OrderRow[]).map((order) => ({
      id: order.order_number,
      customer: order.customers ? `${order.customers.first_name} ${order.customers.last_name}` : 'Client',
      date: new Date(order.created_at).toLocaleDateString('fr-FR', { day: 'numeric', month: 'short', year: 'numeric' }),
      amount: `${Number(order.total).toFixed(0)} DT`,
      status: statusLabels[order.status] ?? order.status,
    })));
  };

  useEffect(() => {
    if (loggedIn) {
      void loadProducts();
      void loadOrders();
    }
  }, [loggedIn]);

  const openProductModal = () => {
    setProductError('');
    setProductForm({ name: '', sku: '', price: '', description: '' });
    setProductImage(null);
    setSizeStock({ S: 0, M: 0, L: 0 });
    setProductModalOpen(true);
  };

  const handleAddProduct = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setProductLoading(true);
    setProductError('');
    const slug = productForm.name.toLowerCase().trim().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
    if (productImage && (!['image/jpeg', 'image/png', 'image/webp', 'image/gif'].includes(productImage.type) || productImage.size > 5 * 1024 * 1024)) {
      setProductError('Choisissez une image JPG, PNG, WEBP ou GIF de 5 Mo maximum.');
      setProductLoading(false);
      return;
    }
    const selectedSizes = Object.entries(sizeStock).filter(([, stock]) => stock > 0);
    if (selectedSizes.length === 0) {
      setProductError('Ajoutez au moins une taille avec un stock supérieur à zéro.');
      setProductLoading(false);
      return;
    }
    let uploadedPath = '';
    if (productImage) {
      uploadedPath = `${crypto.randomUUID()}-${productImage.name.replace(/[^a-zA-Z0-9._-]/g, '-')}`;
      const { error: uploadError } = await supabase.storage.from('product-images').upload(uploadedPath, productImage, { contentType: productImage.type, upsert: false });
      if (uploadError) {
        console.error('product image upload failed', uploadError);
        setProductError('Impossible de téléverser cette image.');
        setProductLoading(false);
        return;
      }
    }
    const { data, error } = await supabase.from('products').insert({
      name: productForm.name.trim(),
      slug,
      sku: productForm.sku.trim().toUpperCase(),
      description: productForm.description.trim(),
      price: Number(productForm.price),
      is_active: true,
      is_featured: false,
    }).select('id, name, sku, price, is_active').maybeSingle();
    if (error || !data) {
      if (uploadedPath) await supabase.storage.from('product-images').remove([uploadedPath]);
      console.error('product creation failed', error);
      setProductError(error?.code === '23505' ? 'Ce nom ou ce SKU existe déjà.' : 'Impossible d’ajouter ce produit.');
    } else {
      const product = data as AdminProduct;
      const { error: sizeError } = await supabase.from('product_sizes').insert(selectedSizes.map(([size, stock]) => ({ product_id: product.id, size, stock })));
      if (sizeError) {
        console.error('product sizes creation failed', sizeError);
        setProductError('Le produit est créé, mais les tailles n’ont pas pu être enregistrées.');
      }
      if (productImage && uploadedPath) {
        const { data: publicImage } = supabase.storage.from('product-images').getPublicUrl(uploadedPath);
        const { error: imageRowError } = await supabase.from('product_images').insert({ product_id: product.id, image_url: publicImage.publicUrl, alt_text: product.name, is_primary: true });
        if (imageRowError) {
          console.error('product image record failed', imageRowError);
          setProductError('Le produit est créé, mais son image n’a pas pu être associée.');
        }
      }
      setProducts((current) => [product, ...current]);
      if (!sizeError) {
        setProductModalOpen(false);
        setActiveSection('products');
      }
    }
    setProductLoading(false);
  };

  const handleLogout = async () => {
    await supabase.auth.signOut();
    setLoggedIn(false);
  };

  if (checkingSession) return <main className="admin-login"><div className="admin-login-card admin-loading"><div className="admin-mark">D</div><p>Vérification de votre session…</p></div></main>;

  if (!loggedIn) return <main className="admin-login"><div className="admin-login-card"><div className="admin-mark">D</div><p className="eyebrow">Espace privé</p><h1>{createMode ? <>Créer un accès<br /><em>Dolara.</em></> : <>Bienvenue chez<br /><em>Dolara.</em></>}</h1><p>{createMode ? 'Créez le compte test administrateur pour accéder à votre boutique.' : 'Connectez-vous pour gérer votre boutique et vos commandes.'}</p><form onSubmit={createMode ? handleSignup : handleLogin}><label>Email professionnel<input type="email" required value={email} onChange={(event) => setEmail(event.target.value)} /></label><label>Mot de passe<input type="password" required value={password} onChange={(event) => setPassword(event.target.value)} placeholder="Votre mot de passe" /></label>{createMode && <p className="auth-hint">Nouvel accès autorisé : admin.nouveau@chez-dolara.tn</p>}{authError && <p className="auth-error" role="alert">{authError}</p>}<button className="admin-primary" type="submit" disabled={authLoading}>{authLoading ? (createMode ? 'Création…' : 'Connexion…') : (createMode ? 'Créer le compte' : 'Se connecter')} <ChevronRight size={16} /></button></form><button className="auth-switch" onClick={() => { setCreateMode(!createMode); setAuthError(''); setEmail(createMode ? 'admin.nouveau@chez-dolara.tn' : 'admin@chez-dolara.tn'); setPassword(''); }}>{createMode ? 'J’ai déjà un compte' : 'Créer un compte test'}</button><a href="/">Retour à la boutique</a></div></main>;

  return <main className="admin-shell"><aside className="admin-sidebar"><a href="/" className="brand admin-brand"><span>CHEZ</span><strong>DOLÄRA</strong></a><p className="admin-label">Espace administration</p><nav><button className={activeSection === 'dashboard' ? 'admin-nav-active' : ''} onClick={() => setActiveSection('dashboard')}><LayoutDashboard size={17} /> Vue d’ensemble</button><button className={activeSection === 'orders' ? 'admin-nav-active' : ''} onClick={() => setActiveSection('orders')}><ShoppingBag size={17} /> Commandes <span className="nav-count">3</span></button><button className={activeSection === 'products' ? 'admin-nav-active' : ''} onClick={() => setActiveSection('products')}><Package size={17} /> Produits</button><button className={activeSection === 'stats' ? 'admin-nav-active' : ''} onClick={() => setActiveSection('stats')}><BarChart3 size={17} /> Statistiques</button><button className={activeSection === 'customers' ? 'admin-nav-active' : ''} onClick={() => setActiveSection('customers')}><Users size={17} /> Clients</button><button className={activeSection === 'settings' ? 'admin-nav-active' : ''} onClick={() => setActiveSection('settings')}><Settings size={17} /> Réglages</button></nav><button className="logout-button" onClick={handleLogout}><LogOut size={16} /> Se déconnecter</button></aside><section className="admin-content"><header className="admin-topbar"><div><p className="eyebrow">Mercredi 16 octobre 2024</p><h1>Bonjour, Dolara.</h1></div><div className="admin-top-actions"><button className="notification-button"><Bell size={18} /><span>3</span></button><div className="admin-avatar">CD</div></div></header><div className="admin-toolbar"><div className="admin-search"><Search size={16} /><input placeholder="Rechercher une commande..." /></div><button className="admin-primary" onClick={openProductModal}><Plus size={16} /> Ajouter un produit</button></div>{activeSection !== 'dashboard' && <section className="admin-panel section-panel"><div className="panel-heading"><div><p className="eyebrow">Espace administration</p><h2>{activeSection === 'products' ? 'Produits' : activeSection === 'orders' ? 'Commandes' : activeSection === 'stats' ? 'Statistiques' : activeSection === 'customers' ? 'Clients' : 'Réglages'}</h2></div>{activeSection === 'products' && <button className="admin-primary" onClick={openProductModal}><Plus size={16} /> Ajouter un produit</button>}</div>{activeSection === 'products' ? <>{productError && <p className="auth-error">{productError}</p>}{products.length === 0 ? <p className="admin-empty">Aucun produit enregistré.</p> : <div className="product-admin-list">{products.map((product) => <div className="product-admin-row" key={product.id}>{product.image_url ? <img className="product-admin-thumb" src={product.image_url} alt="" /> : <div className="product-admin-thumb product-admin-placeholder"><Package size={16} /></div>}<div><strong>{product.name}</strong><small>{product.sku}</small></div><span>{Number(product.price).toFixed(2)} DT</span><span className={product.is_active ? 'product-live' : 'product-off'}>{product.is_active ? 'Actif' : 'Inactif'}</span></div>)}</div>}</> : <p className="admin-empty">Cette section est prête pour votre gestion {activeSection === 'orders' ? 'des commandes' : activeSection === 'stats' ? 'des statistiques' : activeSection === 'customers' ? 'des clients' : 'des réglages'}.</p>}</section>}

<div className="stat-grid"><div className="stat-card"><div className="stat-top"><span>Commandes aujourd’hui</span><ShoppingBag size={17} /></div><strong>{orders.length}</strong><small className="neutral">Commandes enregistrées</small></div><div className="stat-card"><div className="stat-top"><span>Chiffre d’affaires</span><BarChart3 size={17} /></div><strong>{orders.reduce((total, order) => total + Number(order.amount.replace(' DT', '')), 0).toFixed(0)} <small>DT</small></strong><small className="neutral">Chiffre réel enregistré</small></div><div className="stat-card"><div className="stat-top"><span>Produits actifs</span><Package size={17} /></div><strong>{products.length}</strong><small className="neutral">Produits enregistrés</small></div><div className="stat-card alert-card"><div className="stat-top"><span>Stock faible</span><CircleAlert size={17} /></div><strong>—</strong><small className="neutral">Stock calculé par taille</small></div></div><div className="admin-panels"><div className="admin-panel chart-panel"><div className="panel-heading"><div><p className="eyebrow">Performance</p><h2>Ventes de la semaine</h2></div><select><option>7 derniers jours</option><option>30 derniers jours</option></select></div><div className="chart-area"><div className="chart-y"><span>800</span><span>600</span><span>400</span><span>200</span><span>0</span></div><div className="chart-bars">{['Lun','Mar','Mer','Jeu','Ven','Sam','Dim'].map((day, index) => <div className="chart-day" key={day}><div className="bar-wrap"><i style={{ height: `${[42, 58, 39, 72, 55, 88, 66][index]}%` }} /><i className="bar-secondary" style={{ height: `${[30, 45, 28, 58, 41, 70, 52][index]}%` }} /></div><span>{day}</span></div>)}</div></div></div><div className="admin-panel"><div className="panel-heading"><div><p className="eyebrow">En direct</p><h2>Commandes récentes</h2></div><button className="panel-link">Voir tout <ChevronRight size={14} /></button></div><div className="recent-orders">{orders.slice(0, 3).map((order) => <div className="recent-order" key={order.id}><div className="order-avatar">{order.customer.split(' ').map((part) => part[0]).join('')}</div><div><strong>{order.customer}</strong><small>{order.id} · {order.date}</small></div><div className={`order-status ${order.status.toLowerCase().replace(' ', '-')}`}>{order.status}</div><b>{order.amount}</b></div>)}</div></div></div><div className="admin-panel orders-panel"><div className="panel-heading"><div><p className="eyebrow">Gestion</p><h2>Toutes les commandes</h2></div><div className="order-filters">{['Toutes','Nouvelles','En préparation','Livrées'].map((item) => <button className={status === item ? 'active' : ''} key={item} onClick={() => setStatus(item)}>{item}</button>)}</div></div><div className="orders-table"><div className="table-row table-head"><span>Commande</span><span>Client</span><span>Date</span><span>Total</span><span>Statut</span></div>{orders.filter((order) => status === 'Toutes' || order.status === status).map((order) => <div className="table-row" key={order.id}><strong>{order.id}</strong><span>{order.customer}</span><span>{order.date}</span><strong>{order.amount}</strong><span className={`order-status ${order.status.toLowerCase().replace(' ', '-')}`}>{order.status}</span></div>)}</div></div>{productModalOpen && <div className="admin-modal-backdrop" onClick={() => setProductModalOpen(false)}><form className="admin-product-modal" onSubmit={handleAddProduct} onClick={(event) => event.stopPropagation()}><div className="panel-heading"><div><p className="eyebrow">Catalogue</p><h2>Ajouter un produit</h2></div><button className="modal-close-button" type="button" onClick={() => setProductModalOpen(false)}>×</button></div><label>Nom du produit<input required value={productForm.name} onChange={(event) => setProductForm({ ...productForm, name: event.target.value })} placeholder="Ex. Robe Alba" /></label><label>Référence SKU<input required value={productForm.sku} onChange={(event) => setProductForm({ ...productForm, sku: event.target.value })} placeholder="DOL-ALBA-001" /></label><label>Prix en DT<input required min="0" step="0.01" type="number" value={productForm.price} onChange={(event) => setProductForm({ ...productForm, price: event.target.value })} placeholder="119" /></label><label>Image de l’article<input accept="image/jpeg,image/png,image/webp,image/gif" type="file" onChange={(event) => setProductImage(event.target.files?.[0] ?? null)} /></label><fieldset className="size-fieldset"><legend>Tailles et stock</legend><div className="size-grid">{sizeOptions.map((size) => <label className="size-option" key={size}><span><input type="checkbox" checked={sizeStock[size] !== undefined} onChange={(event) => setSizeStock((current) => { const next = { ...current }; if (event.target.checked) next[size] = current[size] ?? 0; else delete next[size]; return next; })} /> {size}</span><input min="0" step="1" type="number" disabled={sizeStock[size] === undefined} value={sizeStock[size] ?? 0} onChange={(event) => setSizeStock((current) => ({ ...current, [size]: Number(event.target.value) }))} /></label>)}</div></fieldset><label>Description<textarea value={productForm.description} onChange={(event) => setProductForm({ ...productForm, description: event.target.value })} placeholder="Décrivez cette pièce" /></label>{productError && <p className="auth-error">{productError}</p>}<button className="admin-primary modal-submit" type="submit" disabled={productLoading}>{productLoading ? 'Enregistrement…' : 'Enregistrer le produit'} <ChevronRight size={16} /></button></form></div>}</section></main>;
}
