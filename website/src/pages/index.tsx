import type { ReactNode } from "react";
import clsx from "clsx";
import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import { useColorMode } from "@docusaurus/theme-common";
import Layout from "@theme/Layout";
import Heading from "@theme/Heading";
import ReleasesSection from "../components/ReleasesSection";
import SeoHead from "../components/SeoHead";

import styles from "./index.module.css";

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  const { colorMode } = useColorMode();
  const logoSrc =
    colorMode === "dark" ? "/img/logo2-dark.png" : "/img/logo2.png";
  return (
    <header className={clsx("hero hero--primary", styles.heroBanner)}>
      <div className="container">
        <img
          src={logoSrc}
          alt="Универсальные инструменты 1С"
          className={styles.heroLogo}
        />
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link className="button button--secondary button--lg" to="/download">
            Скачать
          </Link>
          <Link
            className="button button--outline button--secondary button--lg"
            to="/docs/intro"
          >
            Документация
          </Link>
        </div>
        <div className={styles.badges}>
          <span className={styles.badge}>35+ инструментов</span>
          <span className={styles.badge}>Управляемые формы</span>
          <span className={styles.badge}>Интеграция с БСП</span>
          <span className={styles.badge}>1С 8.3.12+</span>
          <span className={styles.badge}>Open Source (GPL-3.0)</span>
          <span className={styles.badge}>Портативная версия</span>
        </div>
      </div>
    </header>
  );
}

const toolCategories = [
  {
    icon: "🛠️",
    title: "Разработка",
    tools: [
      "Консоль кода",
      "Консоль запросов",
      "Консоль отчётов",
      "Редактор СКД",
      "Редактор JSON",
    ],
    total: 12,
    link: "/docs/tools/development-tools/code-console",
  },
  {
    icon: "📦",
    title: "Работа с данными",
    tools: [
      "Групповая обработка",
      "Поиск дублей",
      "Динамический список",
      "Сравнение объектов",
    ],
    total: 9,
    link: "/docs/tools/data-tools/batch-processing",
  },
  {
    icon: "⚙️",
    title: "Администрирование",
    tools: [
      "Консоль заданий",
      "Структура БД",
      "Удаление помеченных",
      "Файловый менеджер",
      "Лицензии",
    ],
    total: 7,
    link: "/docs/tools/administration-tools/jobs-console",
  },
  {
    icon: "🔄",
    title: "Обмен",
    tools: [
      "Выгрузка/загрузка XML",
      "Универсальный обмен XML",
      "Регистрация изменений",
    ],
    total: 4,
    link: "/docs/tools/exchange-tools/xml-upload-download",
  },
  {
    icon: "🔍",
    title: "Отладка",
    tools: [
      "Данные для отладки",
      "Просмотр значения",
      "Менеджер форм",
      "Временное хранилище",
    ],
    total: 4,
    link: "/docs/tools/debugging-tools/debug-data",
  },
];

function ToolsOverviewSection() {
  return (
    <section className={styles.section}>
      <div className="container">
        <Heading as="h2" className={styles.sectionTitle}>
          Инструменты
        </Heading>
        <div className={styles.toolsGrid}>
          {toolCategories.map((cat) => (
            <div key={cat.title} className={styles.toolCard}>
              <div className={styles.toolCardHeader}>
                <span className={styles.toolCardIcon}>{cat.icon}</span>
                <Heading as="h3">{cat.title}</Heading>
              </div>
              <ul className={styles.toolCardList}>
                {cat.tools.map((tool) => (
                  <li key={tool} className={styles.toolCardItem}>
                    {tool}
                  </li>
                ))}
              </ul>
              <div className={styles.toolCardMore}>
                и другие
              </div>
              <Link to={cat.link} className={styles.toolCardLink}>
                Подробнее →
              </Link>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

export default function Home(): ReactNode {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      title={siteConfig.title}
      description="Универсальные инструменты 1С — open-source подсистема с 44 инструментами для разработки, администрирования и отладки на платформе 1С:Предприятие 8"
    >
      <SeoHead />
      <HomepageHeader />
      <main>
        <ToolsOverviewSection />
        <section className={styles.section}>
          <div className="container">
            <Heading as="h2" className={styles.sectionTitle}>
              Скачать
            </Heading>
            <p
              style={{
                textAlign: "center",
                marginBottom: "2rem",
                color: "var(--ifm-color-emphasis-600)",
              }}
            >
              Выберите вариант поставки подсистемы «Универсальные инструменты
              1С»
            </p>
            <ReleasesSection />
          </div>
        </section>
      </main>
    </Layout>
  );
}
