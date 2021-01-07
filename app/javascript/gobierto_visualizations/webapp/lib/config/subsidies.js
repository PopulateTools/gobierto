// table columns
export const subsidiesColumns = [
  { field: 'beneficiary', translation: I18n.t('gobierto_visualizations.visualizations.subsidies.beneficiary'), format: null, cssClass: '' },
  { field: 'amount', translation: I18n.t('gobierto_visualizations.visualizations.subsidies.amount'), format: 'currency', cssClass: 'right' },
  { field: 'grant_date', translation: I18n.t('gobierto_visualizations.visualizations.subsidies.date'), format: null, cssClass: '' },
];

export const grantedColumns = [
  { field: 'name', translation: I18n.t('gobierto_visualizations.visualizations.subsidies.beneficiary'), format: null, cssClass: '' },
  { field: 'count', translation: I18n.t('gobierto_visualizations.visualizations.subsidies.subsidies'), format: null, cssClass: 'right' },
  { field: 'sum', translation: I18n.t('gobierto_visualizations.visualizations.subsidies.amount'), format: 'currency', cssClass: 'right' },
];

// filters config
export const subsidiesFiltersConfig = [
  {
    id: 'dates',
    title: I18n.t('gobierto_visualizations.visualizations.subsidies.dates'),
    isToggle: true,
    options: []
  },
  {
    id: 'categories',
    title: I18n.t('gobierto_visualizations.visualizations.subsidies.category'),
    isToggle: true,
    options: []
  }
]
