// table columns
export const subsidiesColumns = [
  { field: 'beneficiary_name', translation: I18n.t('gobierto_dashboards.dashboards.subsidies.beneficiary'), format: null, cssClass: '' },
  { field: 'amount', translation: I18n.t('gobierto_dashboards.dashboards.subsidies.amount'), format: 'currency', cssClass: 'right' },
  { field: 'grant_date', translation: I18n.t('gobierto_dashboards.dashboards.subsidies.date'), format: null, cssClass: '' },
];

export const grantedColumns = [
  { field: 'name', translation: I18n.t('gobierto_dashboards.dashboards.subsidies.beneficiary'), format: null, cssClass: '' },
  { field: 'count', translation: I18n.t('gobierto_dashboards.dashboards.subsidies.subsidies'), format: null, cssClass: 'right' },
  { field: 'sum', translation: I18n.t('gobierto_dashboards.dashboards.subsidies.amount'), format: 'currency', cssClass: 'right' },
];

// filters config
export const subsidiesFiltersConfig = [
  {
    id: 'dates',
    title: I18n.t('gobierto_dashboards.dashboards.subsidies.dates'),
    isToggle: true,
    options: []
  },
  {
    id: 'categories',
    title: I18n.t('gobierto_dashboards.dashboards.subsidies.category'),
    isToggle: true,
    options: []
  }
]
