import Vue from "vue";
import "./tablerow.component.scss";

window.GobiertoPlans.TableRowController = (function() {
  function TableRowController() {}

  const PLUGINS = [];
  const template = `
    <div class="tablerow">
      <div class="tablerow__title">{{ title | translate }}</div>
      <div class="tablerow__data">
        <div class="tablerow__item">
          <div>Inicial</div> 
          <div class="tablerow__amount">
            <div class="tablerow__amount--numeric">{{ budgetedAmount | money }}</div>
            <div class="tablerow__amount--percent">100%</div>
          </div>
        </div>
        <div class="tablerow__item">
          <div>Ejecutado</div>
          <div class="tablerow__amount">
            <div class="tablerow__amount--numeric">{{ executedAmount | money }}</div>
            <div class="tablerow__amount--percent">{{ executedPercent }}</div>
          </div>
        </div>
      </div>
      <div class="tablerow__extra">
        <a v-if="detail" :href="detail.link">{{ detail.text }}</a>
      </div>
    </div>
  `;

  TableRowController.prototype.show = function() {
    document.addEventListener("gobierto-plans-mount-plugin", e => handleComponent(e.detail));
  };

  TableRowController.prototype.add = function(key, id) {
    PLUGINS.push({ key, id });
  };

  function handleComponent(params) {
    const { id } = PLUGINS.find(d => d.key === params.key) || {};

    if (id) {
      new Vue({
        el: `#${id}`,
        name: "gobierto-planification__plugin",
        template: template,
        data: {
          title: params.title_translations,
          detail: params.detail,
          budgetedAmount: params.budgeted_amount,
          executedAmount: params.executed_amount,
          executedPercent: params.executed_percentage,
        },
        filters: {
          translate(value) {
            const lang = I18n.locale || "es"
            return value[lang]
          },
          money(value) {
            const lang = I18n.locale || "es"
            return value.toLocaleString(lang, { style: 'currency', currency: 'EUR' })
          }
        }
      })
    }
  }

  return TableRowController;
})();

window.GobiertoPlans.tablerow_controller = new GobiertoPlans.TableRowController();
