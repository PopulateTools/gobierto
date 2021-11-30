import * as htmlToImage from 'html-to-image';

export const baseUrl = `${location.origin}/api/v1/data`

//TODO: extract handleOutsideClick outside directive
export const closableMixin = {
  directives: {
    closable : {
      bind (el, binding, vnode) {
        const handleOutsideClick = (e) => {
          e.stopPropagation()
          const { handler, exclude } = binding.value
          let clickedOnExcludedEl = false
          exclude.forEach(refName => {
            if (!clickedOnExcludedEl ) {
              const excludedEl = vnode.context.$refs[refName]
              if (excludedEl !== undefined) {
                clickedOnExcludedEl = excludedEl.contains(e.target)
              }
            }
          })
          if (!el.contains(e.target) && !clickedOnExcludedEl) {
            vnode.context[handler]()
          }
        }
        document.addEventListener('click', handleOutsideClick)
        document.addEventListener('touchstart', handleOutsideClick)
      },
      unbind () {
        let handleOutsideClick
        document.removeEventListener('click', handleOutsideClick)
        document.removeEventListener('touchstart', handleOutsideClick)
      }
    }
  }
}

export const sqlKeywords = [
  {
    className: "sql",
    text: "ALTER"
  },
  {
    className: "sql",
    text: "AND"
  },
  {
    className: "sql",
    text: "AS"
  },
  {
    className: "sql",
    text: "ASC"
  },
  {
    className: "sql",
    text: "BETWEEN"
  },
  {
    className: "sql",
    text: "BY"
  },
  {
    className: "sql",
    text: "COUNT"
  },
  {
    className: "sql",
    text: "CREATE"
  },
  {
    className: "sql",
    text: "DELETE"
  },
  {
    className: "sql",
    text: "DESC"
  },
  {
    className: "sql",
    text: "DISTINCT"
  },
  {
    className: "sql",
    text: "DROP"
  },
  {
    className: "sql",
    text: "FROM"
  },
  {
    className: "sql",
    text: "GROUP"
  },
  {
    className: "sql",
    text: "HAVING"
  },
  {
    className: "sql",
    text: "IN"
  },
  {
    className: "sql",
    text: "INSERT"
  },
  {
    className: "sql",
    text: "INTO"
  },
  {
    className: "sql",
    text: "IS"
  },
  {
    className: "sql",
    text: "JOIN"
  },
  {
    className: "sql",
    text: "LIKE"
  },
  {
    className: "sql",
    text: "NOT"
  },
  {
    className: "sql",
    text: "ON"
  },
  {
    className: "sql",
    text: "OR"
  },
  {
    className: "sql",
    text: "ORDER"
  },
  {
    className: "sql",
    text: "SELECT"
  },
  {
    className: "sql",
    text: "SET"
  },
  {
    className: "sql",
    text: "TABLE"
  },
  {
    className: "sql",
    text: "UNION"
  },
  {
    className: "sql",
    text: "UPDATE"
  },
  {
    className: "sql",
    text: "VALUES"
  },
  {
    className: "sql",
    text: "WHERE"
  },
  {
    className: "sql",
    text: "LIMIT"
  }
]

export const convertVizToImgMixin = {
  methods: {
    data() {
      return {
        labelVisualize: I18n.t('gobierto_data.projects.visualize') || "",
        labelDashboard: I18n.t('gobierto_data.projects.dashboards') || "",
        labelSavedVisualization: I18n.t("gobierto_data.projects.savedVisualization") || "",
        labelModifiedVizualition: I18n.t("gobierto_data.projects.modifiedVisualization") || "",
        labelQuery: I18n.t("gobierto_data.projects.query") || "",
        items: null,
        config: {},
        vizSaveID: null,
        queryID: '',
        queryName: '',
        user: null,
        queryViz: '',
        isVizElementSavingVisible: false,
        name: '',
        isQuerySavingPromptVisible: false,
        saveLoader: false,
        configMapZoom: { ...this.configMap, zoom: true },
        imageApi: null
      }
    },
    convertVizToImg(opts) {
      let node = document.querySelector('.gobierto-data-visualization--aspect-ratio-16-9');
      const perspectiveChart = document.querySelector("perspective-viewer").shadowRoot
      const perspectiveSidePanel = perspectiveChart.getElementById("side_panel")
      const perspectiveTopPanel = perspectiveChart.getElementById("top_panel")
      perspectiveSidePanel.style.display = "none"
      perspectiveTopPanel.style.display = "none"
      htmlToImage.toPng(node)
        .then(function (dataUrl) {
          this.imageApi = dataUrl
          this.onSaveEventHandler(opts)
        }.bind(this))
        .catch(function (error) {
          console.error('oops, something went wrong!', error);
        });
    }
  }
}
