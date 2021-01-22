// table columns
export const contractsColumns = [
  { field: 'assignee', name: I18n.t('gobierto_visualizations.visualizations.contracts.assignee'), format: null, cssClass: 'bold' },
  { field: 'title', name: I18n.t('gobierto_visualizations.visualizations.contracts.contractor'), format: 'truncate', cssClass: 'largest-width-td ellipsis' },
  { field: 'final_amount_no_taxes', name: I18n.t('gobierto_visualizations.visualizations.contracts.final_amount_no_taxes'), format: 'currency', cssClass: 'right nowrap pr1', type: 'money' },
  { field: 'award_date', name: I18n.t('gobierto_visualizations.visualizations.contracts.date'), format: null, cssClass: 'nowrap pl1 right' }
];

export const tendersColumns = [
  { field: 'contractor', translation: I18n.t('gobierto_visualizations.visualizations.contracts.contractor'), format: null, cssClass: '' },
  { field: 'status', translation: I18n.t('gobierto_visualizations.visualizations.contracts.status'), format: null, cssClass: '' },
  { field: 'submission_date', translation: I18n.t('gobierto_visualizations.visualizations.contracts.submission_date'), format: null, cssClass: 'nowrap' },
];

export const assigneesColumns = [
  { field: 'name', name: I18n.t('gobierto_visualizations.visualizations.contracts.assignee'), format: null, cssClass: 'bold' },
  { field: 'count', name: I18n.t('gobierto_visualizations.visualizations.contracts.contracts'), format: null, cssClass: 'right' },
  { field: 'sum', name: I18n.t('gobierto_visualizations.visualizations.contracts.final_amount_no_taxes'), format: 'currency', cssClass: 'right', type: 'money' },
];

export const assigneesShowColumns = [
  { field: 'title', translation: I18n.t('gobierto_visualizations.visualizations.contracts.assignee'), format: null, cssClass: '' },
  { field: 'final_amount_no_taxes', translation: I18n.t('gobierto_visualizations.visualizations.contracts.final_amount_no_taxes'), format: 'currency', cssClass: 'nowrap pr1' },
  { field: 'award_date', translation: I18n.t('gobierto_visualizations.visualizations.contracts.date'), format: null, cssClass: 'nowrap pl1' },
];

// filters config
export const contractsFiltersConfig = [{
    id: 'dates',
    title: I18n.t('gobierto_visualizations.visualizations.contracts.dates'),
    isToggle: true,
    options: []
  },
  {
    id: 'category_title',
    title: I18n.t('gobierto_visualizations.visualizations.contracts.categories'),
    isToggle: true,
    options: []
  },
  {
    id: 'contract_types',
    title: I18n.t('gobierto_visualizations.visualizations.contracts.contract_type'),
    isToggle: true,
    options: []
  },
  {
    id: 'process_types',
    title: I18n.t('gobierto_visualizations.visualizations.contracts.process_type'),
    isToggle: true,
    options: []
  },
  {
    id: 'contractor',
    title: I18n.t('gobierto_visualizations.visualizations.contracts.entities'),
    isToggle: true,
    options: []
  }
]
