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
      id: "tipus"
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
