import axios from "axios";

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
      multiple: true
    },
    {
      id: "nom-servei-responsable",
      multiple: true
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
      id: "adjudicatari"
    },
    {
      id: "estat",
      multiple: true
    }
  ],
  availableTableFields: [
    {
      id: "nom-projecte"
    },
    {
      id: "estat",
      multiple: true
    },
    {
      id: "import",
      filter: "money"
    }
  ],
  availableProjectFields: [
    {
      id: "nom-servei-responsable",
      multiple: true
    },
    {
      id: "tipus-projecte",
      multiple: true
    },
    {
      id: "notes"
    },
    {
      id: "adreca"
    },
    {
      id: "adjudicatari"
    },
    {
      id: "estat",
      multiple: true
    },
    {
      id: "data-inici",
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
      id: "data-final",
      filter: "date"
    },
    {
      id: "partida",
      filter: "money",
      type: "highlight"
    },
    {
      id: "import",
      filter: "money"
    },
    {
      type: "separator"
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
      id: "tasques",
      type: "table",
      table: {
        columns: [{
          id: "nomactuacio"
        }, {
          id: "nimport",
          filter: "money"
        }]
      }
    }
  ],
  itemSpecialConfiguration: {
    fn: async data => {
      const dataArr = Array.isArray(data) ? data : [data];
      const filterArr = dataArr.filter(d => d.attributes.partida && d.attributes["any-partida"]);
      const allIds = filterArr.map(d => `'${d.attributes.partida}'`).join(",");

      // Avoid the query if there's no code_with_zone (partida)
      if (allIds) {
        const endpoint = `${location.origin}/api/v1/data`;
        const query = `
          SELECT code_with_zone as partida, paranyprs as year, sum(parimport) as budget
          FROM mataro_budgets
          WHERE "parimport" IS NOT NULL
          AND "code_with_zone" IN (${allIds})
          GROUP BY code_with_zone, paranyprs
        `;

        const { data: { data: sql } } = await axios.get(endpoint, {
          params: {
            sql: query.trim()
          }
        })

        for (let index = 0; index < dataArr.length; index++) {
          const { attributes: { partida, "any-partida": year } } = dataArr[index];
          const { budget } = sql.find(d => d.partida === partida && d.year === year) || {};

          dataArr[index].attributes.old_partida = partida
          dataArr[index].attributes.partida = budget ? budget : null
        }
      }

      return Array.isArray(data) ? dataArr : dataArr[0];
    }
  }
};
