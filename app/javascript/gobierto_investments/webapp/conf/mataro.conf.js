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
      id: "estat"
    },
    {
      id: "any-estat",
      allowedValues: ["2024", "2025"]
    },
    {
      id: "tipus"
    },
    {
      id: "tipus-projecte"
    },
    {
      id: "zones"
    },
    {
      id: "consells-territorials"
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
      id: "data-inici-obra"
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
      id: "data-final-obra"
    },
    {
      type: "separator"
    },
    {
      id: "import"
    },
    {
      id: "import-adjudicacio"
    }
  ]
};
