import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docsSidebar: [
    {
      type: 'category',
      label: 'Документация',
      items: [
        'docs/intro',
        'docs/guides/installation',
        'docs/guides/bsp-integration',
        'docs/guides/debugging',
        'docs/guides/debugging-bsp-external',
        'docs/guides/debugging-portable',
        'docs/guides/run-as-user',
        'docs/api/overview',
        'docs/api/code-editor',
      ],
    },
  ],
  toolsSidebar: [
    {
      type: 'category',
      label: 'Инструменты',
      link: {type: 'doc', id: 'tools/index'},
      items: [
        {
          type: 'category',
          label: 'Разработка',
          link: {type: 'doc', id: 'tools/development-tools/_index'},
          items: [
            'tools/development-tools/code-console/intro',
            'tools/development-tools/query-console/intro',
            'tools/development-tools/report-console/intro',
            'tools/development-tools/http-console/intro',
            'tools/development-tools/web-service-console/intro',
            'tools/development-tools/json-editor/intro',
            'tools/development-tools/html-editor/intro',
            'tools/development-tools/skd-editor/intro',
            'tools/development-tools/prototype-editor/intro',
            'tools/development-tools/regex-constructor/intro',
            'tools/development-tools/hrm-query-constructor/intro',
            'tools/development-tools/metadata-navigator/intro',
          ],
        },
        {
          type: 'category',
          label: 'Работа с данными',
          link: {type: 'doc', id: 'tools/data-tools/_index'},
          items: [
            'tools/data-tools/batch-processing/intro',
            'tools/data-tools/constants-editor/intro',
            'tools/data-tools/dynamic-list/intro',
            'tools/data-tools/field-editor/intro',
            'tools/data-tools/search-links/intro',
            'tools/data-tools/deduplication/intro',
            'tools/data-tools/object-comparison/intro',
            'tools/data-tools/data-comparison-console/intro',
            'tools/data-tools/record-count/intro',
          ],
        },
        {
          type: 'category',
          label: 'Администрирование',
          link: {type: 'doc', id: 'tools/administration-tools/_index'},
          items: [
            'tools/administration-tools/jobs-console/intro',
            'tools/administration-tools/db-structure/intro',
            'tools/administration-tools/delete-marked/intro',
            'tools/administration-tools/license-info/intro',
            'tools/administration-tools/file-manager/intro',
            'tools/administration-tools/settings-storages/intro',
            'tools/administration-tools/session-parameters/intro',
          ],
        },
        {
          type: 'category',
          label: 'Обмен',
          link: {type: 'doc', id: 'tools/exchange-tools/_index'},
          items: [
            'tools/exchange-tools/xml-upload-download/intro',
            'tools/exchange-tools/universal-xml-exchange/intro',
            'tools/exchange-tools/change-registration/intro',
            'tools/exchange-tools/table-document-load/intro',
          ],
        },
        {
          type: 'category',
          label: 'Отладка',
          link: {type: 'doc', id: 'tools/debugging-tools/_index'},
          items: [
            'tools/debugging-tools/debug-data/intro',
            'tools/debugging-tools/value-viewer/intro',
            'tools/debugging-tools/form-manager/intro',
            'tools/debugging-tools/temp-storage-editor/intro',
          ],
        },
      ],
    },
  ],
};

export default sidebars;
