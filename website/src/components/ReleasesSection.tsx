import { useEffect, useState } from "react";
import Heading from "@theme/Heading";
import Link from "@docusaurus/Link";
import styles from "../pages/download.module.css";

interface GitHubRelease {
  tag_name: string;
  name: string;
  published_at: string;
  html_url: string;
  prerelease: boolean;
  assets: {
    name: string;
    browser_download_url: string;
    size: number;
    created_at: string;
  }[];
}

interface AssetInfo {
  name: string;
  browser_download_url: string;
  ext: string;
  variant:
    | "UI"
    | "noSSL"
    | "only_dataprocessors"
    | "ssl_only_dataprocessors"
    | "portable";
}

const VARIANT_ORDER: AssetInfo["variant"][] = [
  "UI",
  "portable",
  "ssl_only_dataprocessors",
  "noSSL",
  "only_dataprocessors",
];

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString("ru-RU", {
    day: "numeric",
    month: "long",
    year: "numeric",
  });
}

const VARIANT_NAMES: Record<string, string> = {
  UI: "Полный",
  noSSL: "Без поддержки БСП",
  ssl_only_dataprocessors: "БСП, только инструменты",
  only_dataprocessors: "Минимальный",
  portable: "Портативный",
};

const VARIANT_DESCRIPTIONS: Record<string, string> = {
  UI: "Полный набор инструментов с интерфейсом команд.",
  noSSL: "Версия без поддержки Библиотеки стандартных подсистем (БСП).",
  ssl_only_dataprocessors: "Поддержкой БСП, без реструктуризации",
  only_dataprocessors: "Без поддержки БСП, без реструктуризации",
  portable: "Внешняя обработка для подключения к любой конфигурации.",
};

function detectVariant(filename: string): AssetInfo["variant"] {
  const stem = filename.replace(/\.[^/.]+$/, "");
  if (stem.includes("Portable")) return "portable";
  if (stem.includes("_nossl_only_dataprocessor_8_3_10"))
    return "only_dataprocessors";
  if (stem.includes("_ssl_only_dataprocessor_8_3_10"))
    return "ssl_only_dataprocessors";
  if (stem.includes("_nossl")) return "noSSL";
  return "UI";
}

function extLabel(ext: string): string {
  switch (ext) {
    case "cfe":
      return "CFE";
    case "cf":
      return "CF";
    case "epf":
      return "EPF";
    default:
      return ext.toUpperCase();
  }
}

function VariantGroup({
  variant,
  assets,
  initialExpanded,
}: {
  variant: AssetInfo["variant"];
  assets: AssetInfo[];
  initialExpanded?: boolean;
}) {
  const [expanded, setExpanded] = useState(initialExpanded ?? false);

  const sorted = [...assets].sort((a, b) => {
    const order: Record<string, number> = { cfe: 0, cf: 1, epf: 2 };
    return (order[a.ext] ?? 9) - (order[b.ext] ?? 9);
  });

  return (
    <div className={styles.variantGroup}>
      <button
        className={styles.variantGroupHeader}
        onClick={() => setExpanded(!expanded)}
      >
        <span
          className={`${styles.variantGroupChevron} ${expanded ? styles.chevronOpen : ""}`}
        >
          &#x25B6;
        </span>
        <div>
          <span className={styles.variantGroupName}>
            {VARIANT_NAMES[variant]}
          </span>
          <span className={styles.variantGroupDesc}>
            {VARIANT_DESCRIPTIONS[variant]}
          </span>
        </div>
      </button>
      {expanded && (
        <div className={styles.variantGroupBody}>
          {sorted.map((a) => (
            <div key={a.name} className={styles.fileRow}>
              <span className={styles.fileType}>{extLabel(a.ext)}</span>
              <span className={styles.fileName}>{a.name}</span>
              <Link className={styles.fileDownload} to={a.browser_download_url}>
                Скачать
              </Link>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function ReleaseCard({ release }: { release: GitHubRelease }) {
  const byVariant = new Map<AssetInfo["variant"], AssetInfo[]>();
  for (const v of VARIANT_ORDER) byVariant.set(v, []);

  for (const a of release.assets) {
    const ext = a.name.split(".").pop()?.toLowerCase();
    if (!ext || ext === "zip") continue;

    const variant = detectVariant(a.name);
    if (!byVariant.has(variant)) continue;

    byVariant.get(variant)!.push({
      name: a.name,
      browser_download_url: a.browser_download_url,
      ext,
      variant,
    });
  }

  return (
    <div className={styles.card}>
      <div className={styles.cardHeader}>
        <Link className={styles.cardTagLink} to={release.html_url}>
          {release.tag_name}
        </Link>
        <div className={styles.cardDate}>
          {formatDate(release.published_at)}
        </div>
      </div>

      {VARIANT_ORDER.map((v) => {
        const assets = byVariant.get(v)!;
        if (assets.length === 0) return null;
        return (
          <VariantGroup
            key={v}
            variant={v}
            assets={assets}
            initialExpanded={v === "UI" || v === "portable"}
          />
        );
      })}
    </div>
  );
}

export default function ReleasesSection() {
  const [latest, setLatest] = useState<GitHubRelease | null>(null);
  const [test, setTest] = useState<GitHubRelease | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetch("https://api.github.com/repos/cpr1c/tools_ui_1c/releases?per_page=50")
      .then((res) => {
        if (!res.ok) throw new Error(`GitHub API: ${res.status}`);
        return res.json();
      })
      .then((data) => {
        if (!Array.isArray(data))
          throw new Error("Некорректный ответ от GitHub API");

        const stable = data.find((r: GitHubRelease) => !r.prerelease);
        const testRel = data.find(
          (r: GitHubRelease) => r.tag_name === "v0.0.0",
        );

        if (testRel) {
          const cfAssets = testRel.assets.filter(
            (a: { name: string; created_at: string }) => {
              const ext = a.name.split(".").pop()?.toLowerCase();
              return ext === "cf" || ext === "cfe" || ext === "epf";
            },
          );
          if (cfAssets.length > 0) {
            const minDate = cfAssets.reduce(
              (min: string, a: { created_at: string }) =>
                a.created_at < min ? a.created_at : min,
              cfAssets[0].created_at,
            );
            testRel.published_at = minDate;
          }
        }

        setLatest(stable || null);
        setTest(testRel || null);
      })
      .catch((err) => {
        setError(err.message);
      });
  }, []);

  return (
    <div>
      {error && (
        <div className={styles.error}>
          <p>Не удалось загрузить информацию о релизах.</p>
          <p>{error}</p>
        </div>
      )}

      {!error && !latest && !test && (
        <div className={styles.loading}>Загрузка...</div>
      )}

      {(latest || test) && (
        <div className={styles.columns}>
          {latest && (
            <div className={styles.section}>
              <div className={styles.sectionHeaderArea}>
                <Heading as="h2" className={styles.sectionTitle}>
                  Актуальный релиз
                </Heading>
                <p className={styles.sectionDesc}>
                  Стабильная версия, рекомендованная к использованию.
                </p>
              </div>
              <ReleaseCard release={latest} />
            </div>
          )}

          {test && (
            <div className={styles.section}>
              <div className={styles.sectionHeaderArea}>
                <Heading as="h2" className={styles.sectionTitle}>
                  Тестовый релиз
                </Heading>
                <p className={styles.sectionDesc}>
                  Версия из ветки разработки. Используйте на свой страх и риск.
                </p>
              </div>
              <ReleaseCard release={test} />
            </div>
          )}
        </div>
      )}
    </div>
  );
}
