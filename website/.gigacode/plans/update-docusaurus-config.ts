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

  onBrokenLinks: 'throw',

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
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    image: 'img/docusaurus-social-card.jpg',
    colorMode: {
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'Универсальные инструменты 1С',
      logo: {
        alt: 'Универсальные инструменты 1С',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'Документация',
        },
        {
          type: 'docSidebar',
          sidebarId: 'toolsSidebar',
          position: 'left',
          label: 'Инструменты',
        },
        {
          href: 'https://github.com/cpr1c/tools_ui_1c/releases/latest',
          label: 'Скачать',
          position: 'left',
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
              to: '/docs/tools/index',
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
