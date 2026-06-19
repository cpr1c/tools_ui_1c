import Head from '@docusaurus/Head';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';

export default function SeoHead() {
  const { siteConfig } = useDocusaurusContext();
  const url = 'https://toolc.ru';
  const logoUrl = `${url}/img/logo2.png`;

  const structuredData = {
    '@context': 'https://schema.org',
    '@graph': [
      {
        '@type': 'Organization',
        name: siteConfig.title,
        url,
        logo: logoUrl,
        description: siteConfig.tagline,
      },
      {
        '@type': 'WebSite',
        name: siteConfig.title,
        url,
        description: siteConfig.tagline,
        applicationCategory: 'DeveloperApplication',
        operatingSystem: 'Windows, Linux',
        inLanguage: 'ru-RU',
      },
      {
        '@type': 'SoftwareApplication',
        name: siteConfig.title,
        url,
        applicationCategory: 'DeveloperApplication',
        operatingSystem: 'Windows, Linux',
        offers: {
          '@type': 'Offer',
          price: '0',
          priceCurrency: 'RUB',
        },
      },
      {
        '@type': 'BreadcrumbList',
        itemListElement: [
          { '@type': 'ListItem', position: 1, name: 'Главная', item: url },
          { '@type': 'ListItem', position: 2, name: 'Документация', item: `${url}/docs/intro` },
          { '@type': 'ListItem', position: 3, name: 'Инструменты', item: `${url}/docs/tools/` },
        ],
      },
    ],
  };

  return (
    <Head>
      <link rel="canonical" href={url} />
      <link rel="alternate" hrefLang="ru" href={url} />
      <link rel="alternate" hrefLang="x-default" href={url} />
      <meta property="og:url" content={url} />
      <meta property="og:site_name" content={siteConfig.title} />
      <meta name="twitter:domain" content="toolc.ru" />
      <script type="application/ld+json">
        {JSON.stringify(structuredData)}
      </script>
    </Head>
  );
}
