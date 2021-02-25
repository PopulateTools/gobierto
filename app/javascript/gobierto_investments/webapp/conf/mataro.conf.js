export default {
  title: {
    id: "title_translations"
  },
  description: {
    id: "descripcio-projecte"
  },
  phases: {
    id: "estat"
  },
  location: {
    id: "wkt",
    center: [41.536908, 2.4418503],
    minZoom: 13,
    maxZoom: 16
  },
  availableFilters: [
    {
      id: "daterange",
      startKey: "data-inici",
      endKey: "data-final"
    },
    {
      id: "estat"
    },
    {
      id: "any-partida"
    },
    {
      id: "tipus"
    },
    {
      id: "tipus-projecte"
    },
    {
      id: "import"
    }
  ],
  displayGalleryFieldTags: false,
  availableGalleryFields: [
    {
      id: "element"
    },
    {
      id: "any-estat"
    },
    {
      id: "estat"
    }
  ],
  availableTableFields: [
    {
      id: "nom-projecte"
    },
    {
      id: "estat"
    },
    {
      id: "import"
    }
  ],
  availableProjectFields: [
    {
      id: "nom-servei-gestor"
    },
    {
      id: "tipus"
    },
    {
      id: "element"
    },
    {
      id: "tipus-projecte"
    },
    {
      id: "adreca"
    },
    {
      id: "adjudicatari"
    },
    {
      id: "estat"
    },
    {
      type: "separator"
    },
    {
      id: "data-inici"
    },
    {
      id: "data-final"
    },
    {
      id: "data-adjudicacio"
    },
    {
      id: "data-inici-redaccio"
    },
    {
      id: "data-fi-redaccio"
    },
    {
      type: "separator"
    },
    {
      id: "import",
      filter: "money"
    },
    {
      id: "import-adjudicacio",
      filter: "money"
    },
    {
      id: "import-liquidacio",
      filter: "money"
    },
    {
      id: "budget",
      type: "link",
      composite: true,
      template: "/presupuestos/partidas/:BUDGETLINE/:YEAR/custom/G",
      params: [
        {
          key: "BUDGETLINE",
          value: "partida",
          pattern: "[\\S]+\\.(\\d+)\\w\\.[\\S]+"
        },
        {
          key: "YEAR",
          value: "any-partida"
        }
      ]
    },
    {
      type: "separator"
    },
    {
      id: "documents",
      type: "icon",
      icon: {
        title: "nom",
        href: "url",
        name: "file"
      }
    },
    {
      id: "tasques",
      type: "table",
      table: {
        columns: [
          {
            id: "nomactuacio"
          },
          {
            id: "data"
          },
          {
            id: "nimport",
            filter: "money"
          }
        ]
      }
    }
  ]
};
