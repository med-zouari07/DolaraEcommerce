'use client';

import './admin.css';
import { BarChart3, Bell, ChevronRight, CircleAlert, LayoutDashboard, LogOut, Package, Plus, Search, Settings, ShoppingBag, Users } from 'lucide-react';
import { useEffect, useState } from 'react';
import { supabase } from '../../lib/supabase/client';

const orders = [
  { id: '#DOL-2408', customer: 'Sarra Ben Amor', date: 'Aujourd’hui, 10:42', amount: '238 DT', status: 'Nouvelle' },
  { id: '#DOL-2407', customer: 'Meriem Trabelsi', date: 'Hier, 16:18', amount: '119 DT', status: 'Confirmée' },
  { id: '#DOL-2406', customer: 'Nour Gharbi', date: 'Hier, 11:03', amount: '338 DT', status: 'En préparation' },
  { id: '#DOL-2405', customer: 'Inès Khelifi', date: '12 oct. 2024', amount: '89 DT', status: 'Livrée' },
];

export default function AdminPage() {
  const [loggedIn, setLoggedIn] = useState(false);
  const [checkingSession, setCheckingSession] = useState(true);
  const [authLoading, setAuthLoading] = useState(false);
  const [authError, setAuthError] = useState('');
  const [email, setEmail] = useState('chezdolara@gmail.com');
  const [password, setPassword] = useState('');
  const [status, setStatus] = useState('Toutes');

  useEffect(() => {
    let mounted = true;

    supabase.auth.getSession().then(({ data }) => {
      if (!mounted) return;
      const isAdmin = data.session?.user.app_metadata?.role === 'admin';
      setLoggedIn(isAdmin);
      setCheckingSession(false);
    });

    const { data: listener } = supabase.auth.onAuthStateChange((_event, session) => {
      if (!mounted) return;
      setLoggedIn(session?.user.app_metadata?.role === 'admin');
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
    if (error || data.user?.app_metadata?.role !== 'admin') {
      await supabase.auth.signOut();
      setAuthError('Email, mot de passe ou accès administrateur incorrect.');
    } else {
      setLoggedIn(true);
    }
    setAuthLoading(false);
  };

  const handleLogout = async () => {
    await supabase.auth.signOut();
    setLoggedIn(false);
  };

  if (checkingSession) return <main className="admin-login"><div className="admin-login-card admin-loading"><div className="admin-mark">D</div><p>Vérification de votre session…</p></div></main>;

  if (!loggedIn) return <main className="admin-login"><div className="admin-login-card"><div className="admin-mark">D</div><p className="eyebrow">Espace privé</p><h1>Bienvenue chez<br /><em>Dolara.</em></h1><p>Connectez-vous pour gérer votre boutique et vos commandes.</p><form onSubmit={handleLogin}><label>Email professionnel<input type="email" required value={email} onChange={(event) => setEmail(event.target.value)} /></label><label>Mot de passe<input type="password" required value={password} onChange={(event) => setPassword(event.target.value)} placeholder="Votre mot de passe" /></label>{authError && <p className="auth-error" role="alert">{authError}</p>}<button className="admin-primary" type="submit" disabled={authLoading}>{authLoading ? 'Connexion…' : 'Se connecter'} <ChevronRight size={16} /></button></form><a href="/">Retour à la boutique</a></div></main>;

  return <main className="admin-shell"><aside className="admin-sidebar"><a href="/" className="brand admin-brand"><span>CHEZ</span><strong>DOLÄRA</strong></a><p className="admin-label">Espace administration</p><nav><button className="admin-nav-active"><LayoutDashboard size={17} /> Vue d’ensemble</button><button><ShoppingBag size={17} /> Commandes <span className="nav-count">3</span></button><button><Package size={17} /> Produits</button><button><BarChart3 size={17} /> Statistiques</button><button><Users size={17} /> Clients</button><button><Settings size={17} /> Réglages</button></nav><button className="logout-button" onClick={handleLogout}><LogOut size={16} /> Se déconnecter</button></aside><section className="admin-content"><header className="admin-topbar"><div><p className="eyebrow">Mercredi 16 octobre 2024</p><h1>Bonjour, Dolara.</h1></div><div className="admin-top-actions"><button className="notification-button"><Bell size={18} /><span>3</span></button><div className="admin-avatar">CD</div></div></header><div className="admin-toolbar"><div className="admin-search"><Search size={16} /><input placeholder="Rechercher une commande..." /></div><button className="admin-primary"><Plus size={16} /> Ajouter un produit</button></div><div className="stat-grid"><div className="stat-card"><div className="stat-top"><span>Commandes aujourd’hui</span><ShoppingBag size={17} /></div><strong>12</strong><small className="positive">+18,2% <span>vs. hier</span></small></div><div className="stat-card"><div className="stat-top"><span>Chiffre d’affaires</span><BarChart3 size={17} /></div><strong>1 846 <small>DT</small></strong><small className="positive">+12,5% <span>ce mois</span></small></div><div className="stat-card"><div className="stat-top"><span>Produits actifs</span><Package size={17} /></div><strong>86</strong><small className="neutral">6 nouveautés cette semaine</small></div><div className="stat-card alert-card"><div className="stat-top"><span>Stock faible</span><CircleAlert size={17} /></div><strong>08</strong><small className="warning">À réapprovisionner</small></div></div><div className="admin-panels"><div className="admin-panel chart-panel"><div className="panel-heading"><div><p className="eyebrow">Performance</p><h2>Ventes de la semaine</h2></div><select><option>7 derniers jours</option><option>30 derniers jours</option></select></div><div className="chart-area"><div className="chart-y"><span>800</span><span>600</span><span>400</span><span>200</span><span>0</span></div><div className="chart-bars">{['Lun','Mar','Mer','Jeu','Ven','Sam','Dim'].map((day, index) => <div className="chart-day" key={day}><div className="bar-wrap"><i style={{ height: `${[42, 58, 39, 72, 55, 88, 66][index]}%` }} /><i className="bar-secondary" style={{ height: `${[30, 45, 28, 58, 41, 70, 52][index]}%` }} /></div><span>{day}</span></div>)}</div></div></div><div className="admin-panel"><div className="panel-heading"><div><p className="eyebrow">En direct</p><h2>Commandes récentes</h2></div><button className="panel-link">Voir tout <ChevronRight size={14} /></button></div><div className="recent-orders">{orders.slice(0, 3).map((order) => <div className="recent-order" key={order.id}><div className="order-avatar">{order.customer.split(' ').map((part) => part[0]).join('')}</div><div><strong>{order.customer}</strong><small>{order.id} · {order.date}</small></div><div className={`order-status ${order.status.toLowerCase().replace(' ', '-')}`}>{order.status}</div><b>{order.amount}</b></div>)}</div></div></div><div className="admin-panel orders-panel"><div className="panel-heading"><div><p className="eyebrow">Gestion</p><h2>Toutes les commandes</h2></div><div className="order-filters">{['Toutes','Nouvelles','En préparation','Livrées'].map((item) => <button className={status === item ? 'active' : ''} key={item} onClick={() => setStatus(item)}>{item}</button>)}</div></div><div className="orders-table"><div className="table-row table-head"><span>Commande</span><span>Client</span><span>Date</span><span>Total</span><span>Statut</span></div>{orders.filter((order) => status === 'Toutes' || order.status === status).map((order) => <div className="table-row" key={order.id}><strong>{order.id}</strong><span>{order.customer}</span><span>{order.date}</span><strong>{order.amount}</strong><span className={`order-status ${order.status.toLowerCase().replace(' ', '-')}`}>{order.status}</span></div>)}</div></div></section></main>;
}
