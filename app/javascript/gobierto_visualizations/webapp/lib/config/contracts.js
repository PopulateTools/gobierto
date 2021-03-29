// table columns
export const contractsColumns = [
  { field: 'assignee', name: I18n.t('gobierto_visualizations.visualizations.contracts.assignee'), cssClass: 'bold' },
  { field: 'title', name: I18n.t('gobierto_visualizations.visualizations.contracts.contract'), cssClass: 'largest-width-td ellipsis' },
  { field: 'final_amount_no_taxes', name: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.contract_amount'), cssClass: 'right nowrap pr1', type: 'money' },
  { field: 'gobierto_start_date', name: I18n.t('gobierto_visualizations.visualizations.contracts.formalization_date'), cssClass: 'nowrap pl1 right', type: 'date' },
  { field: 'contractor', name: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.awarding_entity'), cssClass: 'nowrap pl1' },
  { field: 'status', name: I18n.t('gobierto_visualizations.visualizations.contracts.status'), cssClass: 'nowrap pl1' },
  { field: 'contract_type', name: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.type'), cssClass: 'nowrap pl1' },
  { field: 'process_type', name: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.process'), cssClass: 'nowrap pl1' },
  { field: 'category_title', name: I18n.t('gobierto_visualizations.visualizations.subsidies.category'), cssClass: 'nowrap pl1' },
  { field: 'open_proposals_date', name: I18n.t('gobierto_visualizations.visualizations.contracts.tender_date'), cssClass: 'nowrap pl1 right', type: 'date' },
  { field: 'initial_amount_no_taxes', name: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.bid_description'), cssClass: 'nowrap pl1 right', type: 'money' }
];

export const tendersColumns = [
  { field: 'contractor', translation: I18n.t('gobierto_visualizations.visualizations.contracts.contractor'), cssClass: 'bold' },
  { field: 'status', translation: I18n.t('gobierto_visualizations.visualizations.contracts.status'), cssClass: '' },
  { field: 'submission_date', translation: I18n.t('gobierto_visualizations.visualizations.contracts.submission_date'), type: 'date', cssClass: 'nowrap right' },
];

export const assigneesColumns = [
  { field: 'name', name: I18n.t('gobierto_visualizations.visualizations.contracts.assignee'), cssClass: 'bold' },
  { field: 'count', name: I18n.t('gobierto_visualizations.visualizations.contracts.contracts'), cssClass: 'right' },
  { field: 'sum', name: I18n.t('gobierto_visualizations.visualizations.contracts.final_amount_no_taxes'), cssClass: 'right', type: 'money' },
];

export const assigneesShowColumns = [
  { field: 'title', name: I18n.t('gobierto_visualizations.visualizations.contracts.assignee'), cssClass: 'bold' },
  { field: 'final_amount_no_taxes', name: I18n.t('gobierto_visualizations.visualizations.contracts.final_amount_no_taxes'), cssClass: 'nowrap pr1 right', type: 'money' },
  { field: 'gobierto_start_date', name: I18n.t('gobierto_visualizations.visualizations.contracts.date'), cssClass: 'nowrap pl1 right', type: 'date' },
];

// filters config
const responsiveSize = window.innerWidth <= 769 ? false : true
export const contractsFiltersConfig = [{
    id: 'dates',
    title: I18n.t('gobierto_visualizations.visualizations.contracts.dates'),
    isToggle: responsiveSize,
    options: []
  },
  {
    id: 'category_title',
    title: I18n.t('gobierto_visualizations.visualizations.contracts.categories'),
    isToggle: responsiveSize,
    options: []
  },
  {
    id: 'contract_types',
    title: I18n.t('gobierto_visualizations.visualizations.contracts.contract_type'),
    isToggle: responsiveSize,
    options: []
  },
  {
    id: 'process_types',
    title: I18n.t('gobierto_visualizations.visualizations.contracts.process_type'),
    isToggle: responsiveSize,
    options: []
  },
  {
    id: 'contractor',
    title: I18n.t('gobierto_visualizations.visualizations.contracts.entities'),
    isToggle: responsiveSize,
    options: []
  }
]
