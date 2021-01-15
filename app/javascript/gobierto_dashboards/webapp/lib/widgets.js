export const Widgets = {
  HTML: {
    // name is a function to be resolved only when is mounted
    name: () => I18n.t("gobierto_dashboards.widgets.html") || "",
    template: () => import("../components/WidgetHTML"),
    w: 6,
    h: 3,
    minW: 4,
    type: "html",
  },
  INDICATOR: {
    name: () => I18n.t("gobierto_dashboards.widgets.indicator") || "",
    template: () => import("../components/WidgetIndicator"),
    w: 6,
    h: 5,
    minW: 4,
    minH: 3,
    type: "indicator",
    subtypes: {
      individual: {
        name: () => I18n.t("gobierto_dashboards.widgets.individual") || "",
        template: () => import("../components/WidgetIndicatorIndividual")
      },
      table: {
        name: () => I18n.t("gobierto_dashboards.widgets.table") || "",
        template: () => import("../components/WidgetIndicatorTable")
      }
    }
  }
};
