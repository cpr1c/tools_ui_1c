import Layout from '@theme/Layout';
import Heading from '@theme/Heading';
import ReleasesSection from '../components/ReleasesSection';
import SeoHead from '../components/SeoHead';
import styles from './download.module.css';

export default function Download(): JSX.Element {
  return (
    <Layout
      title="Скачать"
      description="Скачать Универсальные инструменты 1С — получите последнюю версию open-source подсистемы для разработки и администрирования 1С">
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
