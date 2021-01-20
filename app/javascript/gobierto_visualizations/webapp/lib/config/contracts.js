// table columns
export const contractsColumns = [
  { field: 'assignee', translation: I18n.t('gobierto_visualizations.visualizations.contracts.assignee'), format: null, cssClass: '' },
  { field: 'title', translation: I18n.t('gobierto_visualizations.visualizations.contracts.contractor'), format: 'truncated', cssClass: 'largest-width-td' },
  { field: 'final_amount_no_taxes', translation: I18n.t('gobierto_visualizations.visualizations.contracts.final_amount_no_taxes'), format: 'currency', cssClass: 'right nowrap pr1' },
  { field: 'award_date', translation: I18n.t('gobierto_visualizations.visualizations.contracts.date'), format: null, cssClass: 'nowrap pl1' },
  { field: 'id', translation: 'id', format: null, cssClass: 'nowrap pl1', type: 'link' },
  { field: 'permalink', translation: 'Permalink', format: null, cssClass: 'nowrap pl1', type: 'link' },
  { field: 'batch_number', translation: I18n.t('gobierto_visualizations.visualizations.contracts.batches'), format: null, cssClass: 'nowrap pl1', type: 'numeric' },
  { field: 'start_date', translation: I18n.t('gobierto_visualizations.visualizations.contracts.start_date'), format: null, cssClass: 'nowrap pl1', type: 'date' },
  { field: 'end_date', translation: I18n.t('gobierto_visualizations.visualizations.contracts.end_date'), format: null, cssClass: 'nowrap pl1', type: 'date' },
  { field: 'duration', translation: I18n.t('gobierto_visualizations.visualizations.contracts.duration'), format: null, cssClass: 'nowrap pl1', type: 'date' },
  { field: 'assignee_type', translation: 'permalink', format: null, cssClass: 'nowrap pl1', type: 'string' },
  { field: 'status', translation: I18n.t('gobierto_visualizations.visualizations.contracts.status'), format: null, cssClass: 'nowrap pl1', type: 'string' },
  { field: 'initial_amount', translation: I18n.t('gobierto_visualizations.visualizations.contracts.initial_amount'), format: null, cssClass: 'nowrap pl1', type: 'money' },
  { field: 'initial_amount_no_taxes', translation: I18n.t('gobierto_visualizations.visualizations.contracts.initial_amount_no_taxes'), format: null, cssClass: 'nowrap pl1', type: 'money' },
  { field: 'final_amount', translation: I18n.t('gobierto_visualizations.visualizations.contracts.final_amount'), format: null, cssClass: 'nowrap pl1', type: 'money' },
  { field: 'contractor', translation: I18n.t('gobierto_visualizations.visualizations.contracts.contractor'), format: null, cssClass: 'nowrap pl1', type: 'string' },
  { field: 'contractor_id', translation: 'permalink', format: null, cssClass: 'nowrap pl1', type: 'numeric' },
  { field: 'contractor_type', translation: I18n.t('gobierto_visualizations.visualizations.contracts.contract_type'), format: null, cssClass: 'nowrap pl1', type: 'string' },
  { field: 'contract_type', translation: I18n.t('gobierto_visualizations.visualizations.contracts.contract_type'), format: null, cssClass: 'nowrap pl1', type: 'string' },
  { field: 'process_type', translation: I18n.t('gobierto_visualizations.visualizations.contracts.process_type'), format: null, cssClass: 'nowrap pl1', type: 'string' },
  { field: 'minor_contract', translation: I18n.t('gobierto_visualizations.visualizations.contracts.minor_contract'), format: null, cssClass: 'nowrap pl1', type: 'string' },
  { field: 'cpvs', translation: 'cpvs', format: null, cssClass: 'nowrap pl1', type: 'numeric' },
  { field: 'category_id', translation: 'permalink', format: null, cssClass: 'nowrap pl1', type: 'numeric' },
  { field: 'category_title', translation: I18n.t('gobierto_visualizations.visualizations.subsidies.category'), format: null, cssClass: 'nowrap pl1', type: 'string' },
  { field: 'open_proposals_date', translation: I18n.t('gobierto_visualizations.visualizations.contracts.open_proposals_date'), format: null, cssClass: 'nowrap pl1', type: 'date' },
  { field: 'submission_date', translation: I18n.t('gobierto_visualizations.visualizations.contracts.submision_date'), format: null, cssClass: 'nowrap pl1', type: 'date' },
  { field: 'number_of_proposals', translation: I18n.t('gobierto_visualizations.visualizations.contracts.number_of_proposals'), format: null, cssClass: 'nowrap pl1', type: 'numeric' },
  { field: 'range', translation: I18n.t('gobierto_visualizations.visualizations.contracts.range'), format: null, cssClass: 'nowrap pl1', type: 'numeric' },
  { field: 'award_date_year', translation: I18n.t('gobierto_visualizations.visualizations.contracts.award_date_year'), format: null, cssClass: 'nowrap pl1', type: 'numeric' },
];

export const tendersColumns = [
  { field: 'contractor', translation: I18n.t('gobierto_visualizations.visualizations.contracts.contractor'), format: null, cssClass: '' },
  { field: 'status', translation: I18n.t('gobierto_visualizations.visualizations.contracts.status'), format: null, cssClass: '' },
  { field: 'submission_date', translation: I18n.t('gobierto_visualizations.visualizations.contracts.submission_date'), format: null, cssClass: 'nowrap' },
];

export const assigneesColumns = [
  { field: 'name', translation: I18n.t('gobierto_visualizations.visualizations.contracts.assignee'), format: null, cssClass: '' },
  { field: 'count', translation: I18n.t('gobierto_visualizations.visualizations.contracts.contracts'), format: null, cssClass: 'right' },
  { field: 'sum', translation: I18n.t('gobierto_visualizations.visualizations.contracts.final_amount_no_taxes'), format: 'currency', cssClass: 'right' },
];

export const assigneesShowColumns = [
  { field: 'title', translation: I18n.t('gobierto_visualizations.visualizations.contracts.assignee'), format: null, cssClass: '' },
  { field: 'final_amount_no_taxes', translation: I18n.t('gobierto_visualizations.visualizations.contracts.final_amount_no_taxes'), format: 'currency', cssClass: 'nowrap pr1' },
  { field: 'award_date', translation: I18n.t('gobierto_visualizations.visualizations.contracts.date'), format: null, cssClass: 'nowrap pl1' },
];

// filters config
export const contractsFiltersConfig = [
  {
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
