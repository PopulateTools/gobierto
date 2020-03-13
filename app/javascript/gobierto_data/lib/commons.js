export const baseUrl = `${location.origin}/api/v1/data`

export const CommonsMixin = {
  directives: {
    clickoutside: {
      bind: function(el, binding, vnode) {
        el.clickOutsideEvent = function(event) {
          if (!(el == event.target || el.contains(event.target))) {
            vnode.context[binding.expression](event);
          }
        };
        document.body.addEventListener('click', el.clickOutsideEvent)
      },
      unbind: function(el) {
        document.body.removeEventListener('click', el.clickOutsideEvent)
      },
      stopProp(event) { event.stopPropagation() }
    }
  }
}

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
	
export const categoriesMixin = {
  methods: {

    getItem(element, attributes) {
      const attr = this.middleware.getAttributesByKey(element.id);

      let value = attributes[element.id];

      if (element.multiple) {
        value = this.translate(attributes[element.id][0].name_translations);
      }

      return {
        ...attr,
        ...element,
        name: this.translate(attr.name_translations),
        value: value
      };
    },
    setItem(element) {
      return {
        ...element,

      };
    },
    setData(data) {
      return data.map(element => this.setItem(element));
    },
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

/*export navMixin = {

}
*/
