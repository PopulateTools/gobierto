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
      id: "estat",
      flat: true
    },
    {
      id: "any-partida",
      flat: true
    },
    {
      id: "tipus",
      flat: true
    },
    {
      id: "tipus-projecte"
    },
    {
      id: "import"
    }
  ],
  availableGalleryFields: [
    {
      id: "estat",
      flat: true
    },
    {
      id: "data-inici",
      filter: "date"
    },
    {
      id: "data-final",
      filter: "date"
    },
    {
      id: "import",
      filter: "money"
    },
    {
      id: "tipus"
    },
    {
      id: "element"
    },
  ],
  availableTableFields: [
    {
      id: "nom-projecte"
    },
    {
      id: "estat",
      flat: true
    },
    {
      id: "import",
      filter: "money"
    }
  ],
  availableProjectFields: [
    {
      id: "nom-servei-gestor",
      flat: true
    },
    {
      id: "tipus"
    },
    {
      id: "element"
    },
    {
      id: "tipus-projecte",
      flat: true
    },
    {
      id: "adreca"
    },
    {
      id: "adjudicatari"
    },
    {
      id: "estat",
      flat: true
    },
    {
      type: "separator"
    },
    {
      id: "data-inici",
      filter: "date"
    },
    {
      id: "data-final",
      filter: "date"
    },
    {
      id: "data-adjudicacio",
      filter: "date"
    },
    {
      id: "data-inici-redaccio",
      filter: "date"
    },
    {
      id: "data-fi-redaccio",
      filter: "date"
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
      params: [{
        key: "BUDGETLINE",
        value: "partida",
        pattern: "[\\S]+\\.(\\d+)\\w\\.[\\S]+"
      },{
        key: "YEAR",
        value: "any-partida"
      }]
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
        columns: [{
          id: "nomactuacio"
        }, {
          id: "data"
        }, {
          id: "nimport",
          filter: "money"
        }]
      }
    }
  ]
};
