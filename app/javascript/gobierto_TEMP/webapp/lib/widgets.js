// TODO: traducir con I18n
export const Widgets = {
  HTML: {
    name: "Contenido HTML",
    template: () => import("../components/WidgetHTML"),
    layout: {
      w: 6,
      h: 4,
      minW: 4,
    }
  },
  INDICATOR: {
    name: "Indicador",
    template: () => import("../components/WidgetIndicator"),
    layout: {
      w: 6,
      h: 6,
      minW: 4,
      minH: 4,
    },
    subtypes: {
      individual: {
        name: "Individual",
        template: () => import("../components/WidgetIndicatorIndividual")
      },
      table: {
        name: "Tabla",
        template: () => import("../components/WidgetIndicatorTable")
      }
    }
  }
};
