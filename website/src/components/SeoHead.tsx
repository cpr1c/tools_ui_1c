import Head from "@docusaurus/Head";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";

export default function SeoHead() {
  const { siteConfig } = useDocusaurusContext();
  const url = "https://toolc.ru";
  const logoUrl = `${url}/img/logo2.png`;
  const socialCardUrl = `${url}/img/logo2.png`;

  const structuredData = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Organization",
        name: siteConfig.title,
        url,
        logo: logoUrl,
        description: siteConfig.tagline,
        sameAs: [
          "https://github.com/cpr1c/tools_ui_1c",
          "https://t.me/tools_ui_1c",
          "https://vk.me/join/gkq/IcSlhiqNT1J2kpLrSTaLfnAYYo1OZdU=",
        ],
      },
      {
        "@type": "WebSite",
        name: siteConfig.title,
        url,
        description: siteConfig.tagline,
        applicationCategory: "DeveloperApplication",
        operatingSystem: "Windows, Linux",
        inLanguage: "ru-RU",
      },
      {
        "@type": "SoftwareApplication",
        name: siteConfig.title,
        url,
        applicationCategory: "DeveloperApplication",
        operatingSystem: "Windows, Linux",
        offers: {
          "@type": "Offer",
          price: "0",
          priceCurrency: "RUB",
        },
        description: siteConfig.tagline,
      },
      {
        "@type": "BreadcrumbList",
        itemListElement: [
          { "@type": "ListItem", position: 1, name: "Главная", item: url },
          {
            "@type": "ListItem",
            position: 2,
            name: "Документация",
            item: `${url}/docs/intro/`,
          },
          {
            "@type": "ListItem",
            position: 3,
            name: "Инструменты",
            item: `${url}/docs/tools/`,
          },
          {
            "@type": "ListItem",
            position: 4,
            name: "Скачать",
            item: `${url}/download/`,
          },
          {
            "@type": "ListItem",
            position: 5,
            name: "Релизы",
            item: `${url}/releases/`,
          },
        ],
      },
      {
        "@type": "FAQPage",
        mainEntity: [
          {
            "@type": "Question",
            name: "Что такое Универсальные инструменты 1С?",
            acceptedAnswer: {
              "@type": "Answer",
              text: "Это open-source подсистема с набором из 44+ инструментов для разработчиков и администраторов на платформе 1С:Предприятие 8. Включает консоль запросов, консоль кода, редактор JSON, HTTP-клиент и многие другие инструменты.",
            },
          },
          {
            "@type": "Question",
            name: "Как установить Универсальные инструменты 1С?",
            acceptedAnswer: {
              "@type": "Answer",
              text: "Подсистема поставляется в трёх вариантах: расширение конфигурации (CFE) для постоянного использования, конфигурация (CF) для старых режимов совместимости и портативная обработка (EPF) для разовых задач.",
            },
          },
          {
            "@type": "Question",
            name: "Какие требования к платформе 1С?",
            acceptedAnswer: {
              "@type": "Answer",
              text: "Подсистема работает на платформе 1С:Предприятие 8.3.10 и выше. Поддерживаются Windows x86/x64, Linux x86/x64 и частично macOS. Доступны толстый и тонкий клиент, веб-клиент — частично.",
            },
          },
          {
            "@type": "Question",
            name: "Сколько стоит Универсальные инструменты 1С?",
            acceptedAnswer: {
              "@type": "Answer",
              text: "Подсистема полностью бесплатна и распространяется под лицензией GNU GPL v3.0. Исходный код открыт, его можно копировать и распространять с сохранением открытости.",
            },
          },
        ],
      },
    ],
  };

  return (
    <Head>
      {/* Канонический URL определяется в docusaurus.config.ts */}
      <link rel="alternate" hrefLang="ru" href={url} />
      <link rel="alternate" hrefLang="x-default" href={url} />
      <meta name="twitter:domain" content="toolc.ru" />
      <meta property="og:image:width" content="1200" />
      <meta property="og:image:height" content="630" />
      <meta
        name="twitter:image:alt"
        content="Универсальные инструменты 1С — open-source подсистема для разработки и администрирования 1С"
      />
      <script type="application/ld+json">
        {JSON.stringify(structuredData)}
      </script>
    </Head>
  );
}
