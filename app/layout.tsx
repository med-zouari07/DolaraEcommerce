import './globals.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Chez Dolara — Women\'s Clothes Shop',
  description: 'Haute sélection, vestiaire d’élégance. Découvrez la collection Chez Dolara à La Sokra, Tunisie.',
  openGraph: { title: 'Chez Dolara — Women\'s Clothes Shop', description: 'L’élégance au quotidien.' },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return <html lang="fr"><body>{children}</body></html>;
}
