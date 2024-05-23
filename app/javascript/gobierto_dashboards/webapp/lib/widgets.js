import WidgetHTML from '../components/WidgetHTML.vue';
import WidgetIndicator from '../components/WidgetIndicator.vue';
import WidgetIndicatorIndividual from '../components/WidgetIndicatorIndividual.vue';
import WidgetIndicatorTable from '../components/WidgetIndicatorTable.vue';

// fields to persist in DB
export const RequiredFields = [
  "i",
  "x",
  "y",
  "w",
  "h",
  "type",
  "subtype",
  "raw",
  "indicator"
]

export const Widgets = {
  HTML: {
    // name is a function to be resolved only when is mounted
    name: () => I18n.t("gobierto_dashboards.widgets.html") || "",
    template: WidgetHTML,
    w: 6,
    h: 3,
    minW: 4,
    type: "html",
  },
  INDICATOR: {
    name: () => I18n.t("gobierto_dashboards.widgets.indicator") || "",
    template: WidgetIndicator,
    w: 6,
    h: 5,
    minW: 4,
    minH: 3,
    type: "indicator",
    subtypes: {
      individual: {
        name: () => I18n.t("gobierto_dashboards.widgets.individual") || "",
        template: WidgetIndicatorIndividual
      },
      table: {
        name: () => I18n.t("gobierto_dashboards.widgets.table") || "",
        template: WidgetIndicatorTable
      }
    }
  }
};
