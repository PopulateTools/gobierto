// table columns
export const subsidiesColumns = [
  { field: 'beneficiary', name: I18n.t('gobierto_visualizations.visualizations.subsidies.beneficiary'), cssClass: 'bold nowrap' },
  { field: 'call', name: I18n.t('gobierto_visualizations.visualizations.subsidies.call'), cssClass: 'bold' },
  { field: 'amount', name: I18n.t('gobierto_visualizations.visualizations.subsidies.amount'), cssClass: 'right', type: 'money' },
  { field: 'grant_date', name: I18n.t('gobierto_visualizations.visualizations.subsidies.date'), cssClass: 'nowrap pl1 right' }
];

export const grantedColumns = [
  { field: 'name', name: I18n.t('gobierto_visualizations.visualizations.subsidies.beneficiary'), cssClass: 'bold' },
  { field: 'count', name: I18n.t('gobierto_visualizations.visualizations.subsidies.subsidies'), cssClass: 'right' },
  { field: 'sum', name: I18n.t('gobierto_visualizations.visualizations.subsidies.amount'), cssClass: 'right', type: 'money' },
];

// filters config
const widthMobile = window.innerWidth > 0 ? window.innerWidth : screen.width
export const subsidiesFiltersConfig = [
  {
    id: 'dates',
    title: I18n.t('gobierto_visualizations.visualizations.subsidies.dates'),
    isToggle: widthMobile <= 700 ? false : true,
    options: []
  },
  {
    id: 'categories',
    title: I18n.t('gobierto_visualizations.visualizations.subsidies.category'),
    isToggle: widthMobile <= 700 ? false : true,
    options: []
  }
]
