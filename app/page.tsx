'use client';

import Image from 'next/image';
import { useEffect, useMemo, useState } from 'react';
import {
  ArrowRight,
  ChevronDown,
  ChevronLeft,
  ChevronRight,
  Heart,
  Menu,
  Minus,
  Package,
  Plus,
  Search,
  ShoppingBag,
  Sparkles,
  Truck,
  UserRound,
  X,
} from 'lucide-react';

type Product = {
  id: number;
  name: string;
  category: string;
  price: number;
  oldPrice?: number;
  image: string;
  tag?: string;
  sizes: string[];
  stock: number;
  description: string;
};

type CartItem = Product & { size: string; quantity: number };

const products: Product[] = [
  {
    id: 1,
    name: 'Robe satinée Alba',
    category: 'Robes',
    price: 119,
    oldPrice: 149,
    image: 'https://images.pexels.com/photos/9968527/pexels-photo-9968527.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
    tag: '-20%',
    sizes: ['S', 'M', 'L', 'XL'],
    stock: 12,
    description: 'Une silhouette fluide et lumineuse, pensée pour les soirées qui comptent.',
  },
  {
    id: 2,
    name: 'Blazer Camille',
    category: 'Vestes',
    price: 179,
    image: 'https://images.pexels.com/photos/7959668/pexels-photo-7959668.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
    tag: 'Nouveau',
    sizes: ['S', 'M', 'L'],
    stock: 8,
    description: 'La pièce structurée qui élève instantanément toutes vos tenues.',
  },
  {
    id: 3,
    name: 'Ensemble Céleste',
    category: 'Ensembles',
    price: 159,
    image: 'https://images.pexels.com/photos/7691346/pexels-photo-7691346.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
    tag: 'Nouveau',
    sizes: ['S', 'M', 'L', 'XL'],
    stock: 5,
    description: 'Un duo décontracté et précis dans une teinte crème intemporelle.',
  },
  {
    id: 4,
    name: 'Top Maya en maille',
    category: 'Tops',
    price: 69,
    image: 'https://images.pexels.com/photos/10745865/pexels-photo-10745865.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
    sizes: ['S', 'M', 'L'],
    stock: 18,
    description: 'Une maille douce et une coupe près du corps pour un essentiel raffiné.',
  },
  {
    id: 5,
    name: 'Chemise Naya',
    category: 'Chemises',
    price: 89,
    image: 'https://images.pexels.com/photos/5393782/pexels-photo-5393782.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
    sizes: ['S', 'M', 'L', 'XL'],
    stock: 10,
    description: 'Une chemise ample au tombé impeccable, à porter ouverte ou nouée.',
  },
  {
    id: 6,
    name: 'Pantalon tailleur Sienna',
    category: 'Pantalons',
    price: 109,
    oldPrice: 129,
    image: 'https://images.pexels.com/photos/3917695/pexels-photo-3917695.jpeg?auto=compress&cs=tinysrgb&h=650&w=940',
    tag: '-15%',
    sizes: ['36', '38', '40', '42'],
    stock: 7,
    description: 'Une coupe élégante et confortable, dessinée pour accompagner vos journées.',
  },
];

const categories = [
  { name: 'Robes', count: '12 pièces', image: products[0].image },
  { name: 'Ensembles', count: '08 pièces', image: products[2].image },
  { name: 'Chemises', count: '16 pièces', image: products[4].image },
  { name: 'Accessoires', count: '24 pièces', image: 'https://images.pexels.com/photos/17938771/pexels-photo-17938771.jpeg?auto=compress&cs=tinysrgb&h=650&w=940' },
];

const formatPrice = (price: number) => `${price.toFixed(0)} DT`;

export default function Home() {
  const [activeCategory, setActiveCategory] = useState('Tout voir');
  const [search, setSearch] = useState('');
  const [cart, setCart] = useState<CartItem[]>([]);
  const [favorites, setFavorites] = useState<number[]>([]);
  const [cartOpen, setCartOpen] = useState(false);
  const [mobileMenu, setMobileMenu] = useState(false);
  const [checkoutOpen, setCheckoutOpen] = useState(false);
  const [orderComplete, setOrderComplete] = useState(false);
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);
  const [selectedSize, setSelectedSize] = useState('M');
  const [activeNav, setActiveNav] = useState('Accueil');

  useEffect(() => {
    const savedCart = window.localStorage.getItem('dolara-cart');
    const savedFavorites = window.localStorage.getItem('dolara-favorites');
    if (savedCart) setCart(JSON.parse(savedCart));
    if (savedFavorites) setFavorites(JSON.parse(savedFavorites));
  }, []);

  useEffect(() => {
    window.localStorage.setItem('dolara-cart', JSON.stringify(cart));
  }, [cart]);

  useEffect(() => {
    window.localStorage.setItem('dolara-favorites', JSON.stringify(favorites));
  }, [favorites]);

  const filteredProducts = useMemo(() => {
    const term = search.toLowerCase().trim();
    return products.filter((product) => {
      const matchesCategory = activeCategory === 'Tout voir' || product.category === activeCategory;
      const matchesSearch = !term || `${product.name} ${product.category} ${product.description}`.toLowerCase().includes(term);
      return matchesCategory && matchesSearch;
    });
  }, [activeCategory, search]);

  const cartCount = cart.reduce((total, item) => total + item.quantity, 0);
  const cartTotal = cart.reduce((total, item) => total + item.price * item.quantity, 0);

  const toggleFavorite = (id: number) => {
    setFavorites((current) => current.includes(id) ? current.filter((favoriteId) => favoriteId !== id) : [...current, id]);
  };

  const addToCart = (product: Product, size = 'M') => {
    setCart((current) => {
      const existing = current.find((item) => item.id === product.id && item.size === size);
      if (existing) return current.map((item) => item.id === product.id && item.size === size ? { ...item, quantity: Math.min(item.quantity + 1, product.stock) } : item);
      return [...current, { ...product, size, quantity: 1 }];
    });
    setSelectedProduct(null);
    setCartOpen(true);
  };

  const updateQuantity = (id: number, size: string, change: number) => {
    setCart((current) => current.map((item) => item.id === id && item.size === size ? { ...item, quantity: Math.max(0, Math.min(item.quantity + change, item.stock)) } : item).filter((item) => item.quantity > 0));
  };

  const removeItem = (id: number, size: string) => setCart((current) => current.filter((item) => !(item.id === id && item.size === size)));

  const selectCategory = (category: string) => {
    setActiveCategory(category);
    setActiveNav(category === 'Tout voir' ? 'Nouveautés' : category);
    document.getElementById('collection')?.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <main className="min-h-screen bg-[#fbfaf7] text-[#241c17]">
      <div className="announcement">Livraison offerte dès 250 DT <span>•</span> La nouvelle collection est arrivée</div>
      <header className="site-header">
        <div className="header-inner">
          <button className="icon-button mobile-only" aria-label="Ouvrir le menu" onClick={() => setMobileMenu(true)}><Menu size={21} /></button>
          <a className="brand" href="#top" aria-label="Chez Dolara accueil"><span>CHEZ</span><strong>DOLÄRA</strong></a>
          <nav className={`main-nav ${mobileMenu ? 'is-open' : ''}`}>
            <button className="mobile-menu-close mobile-only" onClick={() => setMobileMenu(false)}><X size={20} /></button>
            {['Accueil', 'Nouveautés', 'Robes', 'Ensembles', 'Hauts', 'Bas', 'Promotions'].map((item) => (
              <button key={item} className={activeNav === item ? 'active' : ''} onClick={() => { setActiveNav(item); setMobileMenu(false); item === 'Accueil' ? window.scrollTo({ top: 0, behavior: 'smooth' }) : selectCategory(item === 'Hauts' ? 'Tops' : item === 'Bas' ? 'Pantalons' : item === 'Promotions' ? 'Tout voir' : item); }}>{item}</button>
            ))}
          </nav>
          <div className="header-actions">
            <button className="header-action search-trigger" onClick={() => document.getElementById('search')?.focus()}><Search size={18} /><span>Rechercher</span></button>
            <a className="header-action login-action" href="/admin" aria-label="Connexion administrateur"><UserRound size={18} /><span>Connexion</span></a>
            <button className="header-action bag-trigger" aria-label="Ouvrir le panier" onClick={() => setCartOpen(true)}><ShoppingBag size={19} /><span className="bag-count">{cartCount}</span></button>
          </div>
        </div>
      </header>

      <section id="top" className="hero-section">
        <div className="hero-copy">
          <p className="eyebrow"><Sparkles size={14} /> La sélection de saison</p>
          <h1>L'élégance<br /><em>au quotidien.</em></h1>
          <p className="hero-description">Des pièces choisies avec soin, pour révéler la femme que vous êtes et celle que vous devenez.</p>
          <button className="primary-button" onClick={() => selectCategory('Tout voir')}>Découvrir la collection <ArrowRight size={16} /></button>
          <div className="hero-note"><span className="note-line" /> Sélectionnée à La Sokra, pensée pour vous</div>
        </div>
        <div className="hero-visual">
          <div className="hero-image-frame"><Image src="https://images.pexels.com/photos/9968527/pexels-photo-9968527.jpeg?auto=compress&cs=tinysrgb&h=650&w=940" alt="Silhouette mode élégante" fill priority sizes="(max-width: 768px) 100vw, 55vw" /></div>
          <div className="hero-stamp"><Image src="/images/Media_(1).png" alt="Logo Dolara" width={110} height={110} /></div>
          <div className="hero-caption"><strong>01</strong><span> / 04</span><i /></div>
        </div>
      </section>

      <section className="values-strip">
        <div><Truck size={20} /><span><b>Livraison rapide</b><small>Partout en Tunisie</small></span></div>
        <div><Sparkles size={20} /><span><b>Sélection soignée</b><small>Des pièces qui durent</small></span></div>
        <div><Package size={20} /><span><b>Commande simple</b><small>Sans paiement en ligne</small></span></div>
        <div><Heart size={20} /><span><b>Service attentionné</b><small>À votre écoute</small></span></div>
      </section>

      <section className="category-section content-width">
        <div className="section-heading"><div><p className="eyebrow">Explorer</p><h2>Votre style,<br /><em>votre signature.</em></h2></div><button className="text-link" onClick={() => selectCategory('Tout voir')}>Voir tout <ArrowRight size={16} /></button></div>
        <div className="category-grid">
          {categories.map((category, index) => <button className={`category-card category-${index}`} key={category.name} onClick={() => selectCategory(category.name)}><Image src={category.image} alt={category.name} fill sizes="(max-width: 768px) 50vw, 25vw" /><span className="category-overlay"><small>{category.count}</small><strong>{category.name}</strong><ArrowRight size={17} /></span></button>)}
        </div>
      </section>

      <section id="collection" className="collection-section content-width">
        <div className="section-heading collection-heading"><div><p className="eyebrow">Le vestiaire Dolara</p><h2>Les pièces <em>du moment.</em></h2></div><div className="collection-controls"><div className="search-field"><Search size={17} /><input id="search" value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Rechercher une pièce" /></div><button className="filter-button"><span>Filtrer</span><ChevronDown size={15} /></button></div></div>
        <div className="filter-tabs">{['Tout voir', 'Robes', 'Ensembles', 'Tops', 'Vestes', 'Pantalons'].map((category) => <button key={category} className={activeCategory === category ? 'selected' : ''} onClick={() => selectCategory(category)}>{category}</button>)}</div>
        {filteredProducts.length === 0 ? <div className="empty-state"><Search size={28} /><h3>Aucune pièce trouvée</h3><p>Essayez un autre mot-clé ou une autre catégorie.</p></div> : <div className="product-grid">{filteredProducts.map((product) => <article className="product-card" key={product.id}>
          <div className="product-image"><Image src={product.image} alt={product.name} fill sizes="(max-width: 768px) 50vw, 25vw" /><div className="product-badges">{product.tag && <span className={product.tag === 'Nouveau' ? 'new-badge' : 'sale-badge'}>{product.tag}</span>}</div><button className={`favorite-button ${favorites.includes(product.id) ? 'is-favorite' : ''}`} onClick={() => toggleFavorite(product.id)} aria-label="Ajouter aux favoris"><Heart size={18} fill={favorites.includes(product.id) ? 'currentColor' : 'none'} /></button><button className="quick-add" onClick={() => { setSelectedProduct(product); setSelectedSize(product.sizes.includes('M') ? 'M' : product.sizes[0]); }}>Aperçu rapide</button></div>
          <div className="product-info"><div><p className="product-category">{product.category}</p><h3>{product.name}</h3></div><div className="product-price"><strong>{formatPrice(product.price)}</strong>{product.oldPrice && <del>{formatPrice(product.oldPrice)}</del>}</div></div><div className="product-meta"><span>{product.stock < 6 ? 'Dernières pièces' : 'Disponible'}</span><button onClick={() => { setSelectedProduct(product); setSelectedSize(product.sizes.includes('M') ? 'M' : product.sizes[0]); }}>Ajouter <Plus size={14} /></button></div>
        </article>)}</div>}
      </section>

      <section className="editorial-banner"><div className="editorial-image"><Image src="https://images.pexels.com/photos/7588570/pexels-photo-7588570.jpeg?auto=compress&cs=tinysrgb&h=650&w=940" alt="Portrait mode" fill sizes="50vw" /></div><div className="editorial-copy"><p className="eyebrow">L'art de s'habiller</p><h2>La beauté est<br /><em>dans le détail.</em></h2><p>Nous croyons aux vêtements qui racontent une histoire. Une coupe parfaite, une matière choisie, ce détail qui change tout.</p><button className="outline-button" onClick={() => selectCategory('Tout voir')}>Notre histoire <ArrowRight size={16} /></button></div></section>

      <footer className="site-footer"><div className="footer-main"><div className="footer-brand"><a className="brand footer-logo" href="#top"><span>CHEZ</span><strong>DOLÄRA</strong></a><p>Haute sélection.<br />Vestiaire d'élégance.</p></div><div className="footer-column"><h4>Boutique</h4><button onClick={() => selectCategory('Tout voir')}>Nouveautés</button><button onClick={() => selectCategory('Robes')}>Robes</button><button onClick={() => selectCategory('Ensembles')}>Ensembles</button><button onClick={() => selectCategory('Tout voir')}>Promotions</button></div><div className="footer-column"><h4>Besoin d'aide ?</h4><a href="mailto:chezdolara@gmail.com">Contactez-nous</a><span>Livraison & retours</span><span>Guide des tailles</span><span>FAQ</span></div><div className="footer-column footer-contact"><h4>La maison Dolara</h4><span>La Sokra, Tunisie</span><a href="mailto:chezdolara@gmail.com">chezdolara@gmail.com</a><div className="socials"><a href="#top">Instagram</a><a href="#top">Facebook</a></div></div></div><div className="footer-bottom"><span>© 2024 Chez Dolara. Tous droits réservés.</span><span>Women's Clothes Shop</span></div></footer>

      {selectedProduct && <div className="modal-backdrop" onClick={() => setSelectedProduct(null)}><div className="quick-view" onClick={(event) => event.stopPropagation()}><button className="modal-close" onClick={() => setSelectedProduct(null)}><X size={20} /></button><div className="quick-view-image"><Image src={selectedProduct.image} alt={selectedProduct.name} fill sizes="50vw" /></div><div className="quick-view-copy"><p className="eyebrow">{selectedProduct.category}</p><h2>{selectedProduct.name}</h2><div className="modal-price"><strong>{formatPrice(selectedProduct.price)}</strong>{selectedProduct.oldPrice && <del>{formatPrice(selectedProduct.oldPrice)}</del>}</div><p>{selectedProduct.description}</p><div className="size-label"><span>Choisir une taille</span><button>Guide des tailles</button></div><div className="sizes">{selectedProduct.sizes.map((size) => <button key={size} className={selectedSize === size ? 'selected' : ''} onClick={() => setSelectedSize(size)}>{size}</button>)}</div><p className="stock-line"><span className="stock-dot" /> {selectedProduct.stock} pièces disponibles</p><button className="primary-button full-button" onClick={() => addToCart(selectedProduct, selectedSize)}>Ajouter au panier <ShoppingBag size={17} /></button></div></div></div>}

      {cartOpen && <div className="drawer-backdrop" onClick={() => setCartOpen(false)}><aside className="cart-drawer" onClick={(event) => event.stopPropagation()}><div className="drawer-header"><div><p className="eyebrow">Votre sélection</p><h2>Votre panier <span>({cartCount})</span></h2></div><button className="modal-close" onClick={() => setCartOpen(false)}><X size={20} /></button></div>{cart.length === 0 ? <div className="empty-cart"><ShoppingBag size={38} /><h3>Votre panier est vide</h3><p>Ajoutez une pièce qui vous ressemble.</p><button className="outline-button" onClick={() => { setCartOpen(false); selectCategory('Tout voir'); }}>Découvrir la boutique</button></div> : <><div className="cart-items">{cart.map((item) => <div className="cart-item" key={`${item.id}-${item.size}`}><div className="cart-item-image"><Image src={item.image} alt={item.name} fill sizes="80px" /></div><div className="cart-item-copy"><h3>{item.name}</h3><span>Taille : {item.size}</span><div className="cart-item-bottom"><div className="quantity"><button onClick={() => updateQuantity(item.id, item.size, -1)}><Minus size={13} /></button><span>{item.quantity}</span><button onClick={() => updateQuantity(item.id, item.size, 1)}><Plus size={13} /></button></div><strong>{formatPrice(item.price * item.quantity)}</strong></div></div><button className="remove-item" onClick={() => removeItem(item.id, item.size)}><X size={14} /></button></div>)}</div><div className="cart-summary"><div><span>Sous-total</span><strong>{formatPrice(cartTotal)}</strong></div><p>Livraison calculée à la confirmation de commande.</p><button className="primary-button full-button" onClick={() => { setCartOpen(false); setCheckoutOpen(true); }}>Passer la commande <ArrowRight size={16} /></button></div></>}</aside></div>}

      {checkoutOpen && <div className="modal-backdrop" onClick={() => !orderComplete && setCheckoutOpen(false)}><div className="checkout-modal" onClick={(event) => event.stopPropagation()}>{orderComplete ? <div className="order-success"><div className="success-icon"><Sparkles size={25} /></div><p className="eyebrow">Merci pour votre confiance</p><h2>Votre commande<br /><em>est confirmée.</em></h2><p>Votre commande <strong>#DOL-2408</strong> a bien été enregistrée. Notre équipe vous contactera prochainement pour organiser la livraison.</p><button className="primary-button" onClick={() => { setCheckoutOpen(false); setOrderComplete(false); setCart([]); }}>Continuer mes achats <ArrowRight size={16} /></button></div> : <><button className="modal-close" onClick={() => setCheckoutOpen(false)}><X size={20} /></button><div className="checkout-heading"><p className="eyebrow">Dernière étape</p><h2>Finaliser votre commande</h2><p>Un conseiller Dolara vous contactera pour confirmer votre commande.</p></div><div className="checkout-layout"><form className="checkout-form" onSubmit={(event) => { event.preventDefault(); setOrderComplete(true); }}><div className="form-row"><label>Prénom<input required placeholder="Votre prénom" /></label><label>Nom<input required placeholder="Votre nom" /></label></div><label>Téléphone<input required type="tel" placeholder="+216 00 000 000" /></label><label>Email<input required type="email" placeholder="votre@email.com" /></label><label>Adresse de livraison<input required placeholder="Rue, quartier, numéro" /></label><div className="form-row"><label>Gouvernorat<select defaultValue="Tunis"><option>Tunis</option><option>Ariana</option><option>Ben Arous</option><option>La Manouba</option><option>Autre</option></select></label><label>Ville<input required placeholder="Votre ville" /></label></div><label>Note (facultatif)<textarea placeholder="Une précision pour la livraison ?" /></label><button className="primary-button full-button" type="submit">Confirmer la commande <ArrowRight size={16} /></button></form><div className="order-summary"><h3>Votre sélection</h3>{cart.map((item) => <div className="summary-item" key={`${item.id}-${item.size}`}><span>{item.name} <small>× {item.quantity} · {item.size}</small></span><strong>{formatPrice(item.price * item.quantity)}</strong></div>)}<div className="summary-total"><span>Total estimé</span><strong>{formatPrice(cartTotal)}</strong></div><p className="no-payment"><Package size={15} /> Paiement à la livraison</p></div></div></>}</div></div>}
    </main>
  );
}
