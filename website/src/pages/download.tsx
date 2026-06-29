import Layout from "@theme/Layout";
import Heading from "@theme/Heading";
import ReleasesSection from "../components/ReleasesSection";
import SeoHead from "../components/SeoHead";
import styles from "./download.module.css";

export default function Download(): JSX.Element {
  return (
    <Layout
      title="Скачать Универсальные инструменты 1С — бесплатно"
      description="Скачать Универсальные инструменты 1С бесплатно. Расширение конфигурации (CFE), конфигурация (CF) и портативная обработка (EPF). Open-source подсистема для разработки и администрирования 1С под лицензией GNU GPL v3.0."
    >
      <SeoHead />
      <div className={styles.page}>
        <Heading as="h1" className={styles.pageTitle}>
          Скачать
        </Heading>
        <p className={styles.pageSubtitle}>
          Выберите вариант поставки подсистемы «Универсальные инструменты 1С»
        </p>
        <ReleasesSection />
      </div>
    </Layout>
  );
}
