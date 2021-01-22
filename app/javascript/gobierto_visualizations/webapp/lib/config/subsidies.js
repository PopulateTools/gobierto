// table columns
export const subsidiesColumns = [
  { field: 'beneficiary', name: I18n.t('gobierto_visualizations.visualizations.subsidies.beneficiary'), format: null, cssClass: 'bold' },
  { field: 'amount', name: I18n.t('gobierto_visualizations.visualizations.subsidies.amount'), format: 'currency', cssClass: 'right', type: 'money' },
  { field: 'grant_date', name: I18n.t('gobierto_visualizations.visualizations.subsidies.date'), format: null, cssClass: 'nowrap pl1 right' },
];

export const grantedColumns = [
  { field: 'name', name: I18n.t('gobierto_visualizations.visualizations.subsidies.beneficiary'), format: null, cssClass: 'bold' },
  { field: 'count', name: I18n.t('gobierto_visualizations.visualizations.subsidies.subsidies'), format: null, cssClass: 'right' },
  { field: 'sum', name: I18n.t('gobierto_visualizations.visualizations.subsidies.amount'), format: 'currency', cssClass: 'right', type: 'money' },
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
