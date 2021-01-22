// table columns
export const contractsColumns = [
  { field: 'assignee', name: I18n.t('gobierto_visualizations.visualizations.contracts.assignee'), format: null, cssClass: 'bold' },
  { field: 'title', name: I18n.t('gobierto_visualizations.visualizations.contracts.contractor'), format: 'truncate', cssClass: 'largest-width-td ellipsis' },
  { field: 'final_amount_no_taxes', name: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.contract_amount'), format: 'currency', cssClass: 'right nowrap pr1', type: 'money' },
  { field: 'award_date', name: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.awarding'), format: null, cssClass: 'nowrap pl1 right' },
  { field: 'contractor', name: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.awarding_entity'), format: null, cssClass: 'nowrap pl1' },
  { field: 'status', name: I18n.t('gobierto_visualizations.visualizations.contracts.status'), format: null, cssClass: 'nowrap pl1' },
  { field: 'contract_type', name: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.type'), format: null, cssClass: 'nowrap pl1' },
  { field: 'process_type', name: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.process'), format: null, cssClass: 'nowrap pl1' },
  { field: 'category_title', name: I18n.t('gobierto_visualizations.visualizations.subsidies.category'), format: null, cssClass: 'nowrap pl1' },
  { field: 'open_proposals_date', name: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.open_proposals_date'), format: null, cssClass: 'nowrap pl1' },
  { field: 'submission_date', name: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.submission_date'), format: null, cssClass: 'nowrap pl1' },
  { field: 'initial_amount_no_taxes', name: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.bid_description'), format: null, cssClass: 'nowrap pl1 right', type: 'money' }
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
  { field: 'title', name: I18n.t('gobierto_visualizations.visualizations.contracts.assignee'), format: null, cssClass: '' },
  { field: 'final_amount_no_taxes', name: I18n.t('gobierto_visualizations.visualizations.contracts.final_amount_no_taxes'), format: 'currency', cssClass: 'nowrap pr1' },
  { field: 'award_date', name: I18n.t('gobierto_visualizations.visualizations.contracts.date'), format: null, cssClass: 'nowrap pl1' },
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
