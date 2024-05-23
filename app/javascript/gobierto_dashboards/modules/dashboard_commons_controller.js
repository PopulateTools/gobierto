import Vue from 'vue';

Vue.config.productionTip = false;

export class GobiertoDashboardCommonsController {
  constructor({ selector, render, ...moreOptions } = {}) {
    this.selector = selector
    this.app = new Vue({
      data: moreOptions,
      render
    });
  }

  mount() {
    this.app.$mount(this.selector)
  }
}
