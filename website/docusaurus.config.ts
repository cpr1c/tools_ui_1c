import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Универсальные инструменты 1С',
  tagline: 'Набор обработок для разработчиков и администраторов систем на платформе 1С',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://toolc.ru',
  baseUrl: '/',

  organizationName: 'cpr1c',
  projectName: 'tools_ui_1c',

  onBrokenLinks: 'warn',


  i18n: {
    defaultLocale: 'ru',
    locales: ['ru'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          editUrl: 'https://github.com/cpr1c/toolc-ru/tree/main/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
        sitemap: {
          lastmod: 'date',
          changefreq: 'weekly',
          priority: 0.7,
          ignorePatterns: ['/admin/**', '/private/**'],
        },
      } satisfies Preset.Options,
    ],
  ],

  plugins: [
    [
      require.resolve('@easyops-cn/docusaurus-search-local'),
      {
        language: ['ru', 'en'],
        indexDocs: true,
        indexBlog: false,
        indexPages: true,
      },
    ],
  ],

  themeConfig: {
    image: 'img/social-card.jpg',
    metadata: [
      {
        name: 'description',
        content: 'Универсальные инструменты 1С — open-source подсистема с 44+ инструментами для разработки, администрирования и отладки на платформе 1С:Предприятие 8',
      },
      {
        name: 'author',
        content: 'Центр прикладных разработок',
      },
      {
        name: 'keywords',
        content: '1С, универсальные инструменты, разработка 1С, администрирование 1С, open-source 1С, обработки 1С, консоль запросов 1С, отладка 1С, инструменты 1С, подсистема 1С, CPR1C',
      },
      {
        property: 'og:type',
        content: 'website',
      },
      {
        property: 'og:site_name',
        content: 'Универсальные инструменты 1С',
      },
      {
        property: 'og:url',
        content: 'https://toolc.ru',
      },
      {
        property: 'og:title',
        content: 'Универсальные инструменты 1С',
      },
      {
        property: 'og:description',
        content: 'Open-source подсистема с 44+ инструментами для разработки, администрирования и отладки на платформе 1С:Предприятие 8',
      },
      {
        property: 'og:image',
        content: 'https://toolc.ru/img/social-card.jpg',
      },
      {
        property: 'og:locale',
        content: 'ru_RU',
      },
      {
        name: 'twitter:card',
        content: 'summary_large_image',
      },
      {
        name: 'twitter:site',
        content: '@tools_ui_1c',
      },
      {
        name: 'twitter:title',
        content: 'Универсальные инструменты 1С',
      },
      {
        name: 'twitter:description',
        content: 'Open-source подсистема с 44+ инструментами для разработки, администрирования и отладки на платформе 1С:Предприятие 8',
      },
      {
        name: 'twitter:image',
        content: 'https://toolc.ru/img/social-card.jpg',
      },
      {
        rel: 'canonical',
        href: 'https://toolc.ru',
      },
    ],
    colorMode: {
      respectPrefersColorScheme: false,
    },
    navbar: {
      title: 'Универсальные инструменты 1С',
      logo: {
        alt: 'Универсальные инструменты 1С',
        src: 'img/logo.png',
        srcDark: 'img/logo-dark.png',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'Документация',
        },
        {
          to: '/releases',
          label: 'Релизы',
          position: 'left',
        },
        {
          type: 'docSidebar',
          sidebarId: 'contributingSidebar',
          position: 'left',
          label: 'Разработчикам',
        },
        {
          to: '/download',
          label: 'Скачать',
          position: 'left',
        },
        {
          href: 'https://vk.me/join/gkq/IcSlhiqNT1J2kpLrSTaLfnAYYo1OZdU=',
          label: 'VK',
          position: 'right',
        },
        {
          href: 'https://t.me/tools_ui_1c',
          label: 'Telegram',
          position: 'right',
        },
        {
          href: 'https://github.com/cpr1c/tools_ui_1c',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Документация',
          items: [
            {
              label: 'Введение',
              to: '/docs/intro',
            },
            {
              label: 'Установка',
              to: '/docs/guides/installation',
            },
            {
              label: 'Инструменты',
              to: '/docs/tools/',
            },
            {
              label: 'Разработчикам',
              to: '/docs/contributing/overview',
            },
          ],
        },
        {
          title: 'Сообщество',
          items: [
            {
              label: 'Telegram',
              href: 'https://t.me/tools_ui_1c',
            },
            {
              label: 'VK',
              href: 'https://vk.me/join/gkq/IcSlhiqNT1J2kpLrSTaLfnAYYo1OZdU=',
            },
            {
              label: 'Issues',
              href: 'https://github.com/cpr1c/tools_ui_1c/issues',
            },
          ],
        },
        {
          title: 'Проект',
          items: [
            {
              label: 'Репозиторий',
              href: 'https://github.com/cpr1c/tools_ui_1c',
            },
            {
              label: 'Поддержать проект (донаты)',
              href: 'https://donate.stream/ya410011848843350',
            },
            {
              label: 'Лицензия GPL-3.0',
              href: 'https://github.com/cpr1c/tools_ui_1c/blob/master/LICENSE',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Центр прикладных разработок. Лицензия GNU GPL v3.0.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['bash'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;