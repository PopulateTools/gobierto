// TODO: traducir con I18n
export const Widgets = {
  HTML: {
    type: "Contenido HTML",
    template: () => import("../components/WidgetHTML"),
    layout: {
      w: 6,
      h: 4,
      minW: 4,
    }
  },
  INDICATOR: {
    type: "Indicador",
    template: () => import("../components/WidgetIndicator"),
    layout: {
      w: 6,
      h: 6,
      minW: 4,
      minH: 4,
    },
    subtypes: {
      individual: () => import("../components/WidgetIndicatorIndividual"),
      table: () => import("../components/WidgetIndicatorTable")
    }
  }
};
