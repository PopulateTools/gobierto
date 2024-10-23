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
      id: "date",
      startKey: "data-inici",
      endKey: "data-final",
    },
    {
      id: "estat"
    },
    {
      id: "any-estat"
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
      id: "import",
      sort: "desc"
    }
  ],
  availableProjectFields: [
    {
      id: "tipus-projecte-tipus-concatenation"
    },
    {
      id: "element"
    },
    {
      id: "adreca"
    },
    {
      id: "adjudicatari"
    },
    {
      type: "separator"
    },
    {
      id: "data-inici-redaccio"
    },
    {
      id: "data-aprovacio"
    },
    {
      id: "data-adjudicacio"
    },
    {
      id: "data-inici"
    },
    {
      id: "data-final"
    },
    {
      type: "separator"
    },
    {
      id: "import"
    },
    {
      id: "import-adjudicacio"
    },
    {
      id: "import-liquidacio"
    },
    {
      id: "partida"
    }
  ]
};
