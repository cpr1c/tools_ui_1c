import { useEffect, useRef, useState } from "react";
import Layout from "@theme/Layout";
import Heading from "@theme/Heading";
import Link from "@docusaurus/Link";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import SeoHead from "../components/SeoHead";
import styles from "./releases.module.css";

interface GitHubRelease {
  tag_name: string;
  name: string;
  published_at: string;
  html_url: string;
  body: string | null;
  prerelease: boolean;
  assets: { name: string; browser_download_url: string }[];
}

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString("ru-RU", {
    day: "numeric",
    month: "long",
    year: "numeric",
  });
}

function ReleaseCard({ release }: { release: GitHubRelease }) {
  const [expanded, setExpanded] = useState(false);
  const [overflows, setOverflows] = useState(false);
  const bodyRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = bodyRef.current;
    if (el && el.scrollHeight > el.clientHeight) {
      setOverflows(true);
    }
  }, []);

  return (
    <div className={styles.release}>
      <div className={styles.releaseHeader}>
        <div className={styles.releaseHeaderLeft}>
          <Link className={styles.releaseTagLink} to={release.html_url}>
            {release.tag_name}
          </Link>
          {release.prerelease && (
            <span className={styles.prerelease}>pre-release</span>
          )}
        </div>
        <span className={styles.releaseDate}>
          {formatDate(release.published_at)}
        </span>
      </div>
      {release.name && release.name !== release.tag_name && (
        <div className={styles.releaseName}>{release.name}</div>
      )}
      {release.body && (
        <div className={styles.releaseBodyWrapper}>
          <div
            ref={bodyRef}
            className={`${styles.releaseBody} ${expanded ? styles.releaseBodyExpanded : styles.releaseBodyCollapsed} ${overflows && !expanded ? styles.releaseBodyFade : ""}`}
          >
            <ReactMarkdown remarkPlugins={[remarkGfm]}>
              {release.body.replace(
                /(^|\s)#(\d+)/g,
                "$1[#$2](https://github.com/cpr1c/tools_ui_1c/issues/$2)",
              )}
            </ReactMarkdown>
          </div>
          {overflows && (
            <button
              className={styles.expandToggle}
              onClick={() => setExpanded(!expanded)}
            >
              {expanded ? "Свернуть" : "Показать полностью"}
            </button>
          )}
        </div>
      )}
    </div>
  );
}

const PAGE_SIZE = 5;

export default function Releases(): JSX.Element {
  const [allReleases, setAllReleases] = useState<GitHubRelease[] | null>(null);
  const [visibleCount, setVisibleCount] = useState(PAGE_SIZE);
  const [error, setError] = useState<string | null>(null);
  const sentinelRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    fetch("https://api.github.com/repos/cpr1c/tools_ui_1c/releases?per_page=50")
      .then((res) => {
        if (!res.ok) throw new Error(`GitHub API: ${res.status}`);
        return res.json();
      })
      .then((data) => {
        if (Array.isArray(data)) {
          setAllReleases(data.filter((r: GitHubRelease) => !r.prerelease));
        } else {
          throw new Error("Некорректный ответ от GitHub API");
        }
      })
      .catch((err) => {
        setError(err.message);
      });
  }, []);

  useEffect(() => {
    if (!allReleases) return;
    const sentinel = sentinelRef.current;
    if (!sentinel) return;

    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && visibleCount < allReleases.length) {
          setVisibleCount((prev) =>
            Math.min(prev + PAGE_SIZE, allReleases.length),
          );
        }
      },
      { rootMargin: "200px" },
    );

    observer.observe(sentinel);
    return () => observer.disconnect();
  }, [allReleases, visibleCount]);

  const visibleReleases = allReleases ? allReleases.slice(0, visibleCount) : [];
  const hasMore = allReleases !== null && visibleCount < allReleases.length;

  return (
    <Layout
      title="История релизов Универсальных инструментов 1С"
      description="История релизов Универсальных инструментов 1С — все выпуски open-source подсистемы для разработки и администрирования 1С. Список версий, даты выхода, список изменений и ссылки для скачивания."
    >
      <SeoHead />
      <div className={styles.page}>
        <Heading as="h1" className={styles.pageTitle}>
          История релизов
        </Heading>
        <p className={styles.pageSubtitle}>
          Все выпуски подсистемы «Универсальные инструменты 1С»
        </p>

        {error && (
          <div className={styles.error}>
            <p>Не удалось загрузить список релизов.</p>
            <p className={styles.pageSubtitle}>{error}</p>
            <Link
              className="button button--secondary"
              to="https://github.com/cpr1c/tools_ui_1c/releases"
            >
              Открыть на GitHub
            </Link>
          </div>
        )}

        {!error && allReleases === null && (
          <div className={styles.loading}>Загрузка релизов...</div>
        )}

        {!error && allReleases !== null && allReleases.length === 0 && (
          <div className={styles.empty}>Релизы не найдены.</div>
        )}

        {visibleReleases.map((r) => (
          <ReleaseCard key={r.tag_name} release={r} />
        ))}

        {hasMore && (
          <div ref={sentinelRef} className={styles.sentinel}>
            Загрузка...
          </div>
        )}
      </div>
    </Layout>
  );
}
