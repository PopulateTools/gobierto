export const contractsColumns = [
  {field: 'assignee', translation: I18n.t('gobierto_dashboards.dashboards.contracts.assignee'), format: null},
  {field: 'title', translation: I18n.t('gobierto_dashboards.dashboards.contracts.contractor'), format: 'truncated'},
  {field: 'final_amount', translation: I18n.t('gobierto_dashboards.dashboards.contracts.final_amount'), format: 'currency'},
  {field: 'start_date', translation: I18n.t('gobierto_dashboards.dashboards.contracts.date'), format: null},
];

export const tendersColumns = [
  {field: 'contractor', translation: I18n.t('gobierto_dashboards.dashboards.contracts.contractor'), format: null},
  {field: 'status', translation: I18n.t('gobierto_dashboards.dashboards.contracts.status'), format: null},
  {field: 'submission_date', translation: I18n.t('gobierto_dashboards.dashboards.contracts.submission_date'), format: null},
];

export const assigneesColumns = [
  {field: 'name', translation: I18n.t('gobierto_dashboards.dashboards.contracts.assignee'), format: null},
  {field: 'count', translation: I18n.t('gobierto_dashboards.dashboards.contracts.contracts'), format: 'quantity'},
  {field: 'sum', translation: I18n.t('gobierto_dashboards.dashboards.contracts.final_amount'), format: 'currency'},
];

export const filtersConfig = [
  {
    id: 'dates',
    title: I18n.t('gobierto_dashboards.dashboards.contracts.dates'),
    isToggle: true,
    options: []
  },
  {
    id: 'contract_types',
    title: I18n.t('gobierto_dashboards.dashboards.contracts.contract_type'),
    isToggle: true,
    options: [
      {id: 0, title: 'Gestión de servicios públicos', counter: 0, isOptionChecked: false},
      {id: 1, title: 'Obras', counter: 0, isOptionChecked: false},
      {id: 2, title: 'Servicios', counter: 0, isOptionChecked: false},
      {id: 3, title: 'Suministros', counter: 0, isOptionChecked: false},
    ]
  },
  {
    id: 'process_types',
    title: I18n.t('gobierto_dashboards.dashboards.contracts.process_type'),
    isToggle: true,
    options: [
        {id: 0, title: 'Abierto', counter: 0, isOptionChecked: false},
        {id: 1, title: 'Abierto simplificado', counter: 0, isOptionChecked: false},
        {id: 2, title: 'Basado en Acuerdo Marco', counter: 0, isOptionChecked: false},
        {id: 3, title: 'Negociado con publicidad', counter: 0, isOptionChecked: false},
        {id: 4, title: 'Negociado sin publicidad', counter: 0, isOptionChecked: false}
      ]
  }
]
