import { Card } from './card.js';

export class getBudgetLevelData extends Card {
  constructor() {
    super();

    this.data = null;
    this.url = $("body").data("bubbles-data");
  }

  getData(callback) {
    if (this.url) {
      // empty the Authorization header
      this.handlePromise(this.url, { headers: new Headers() }).then(data => {
        this.data = data;

        window.budgetLevels = this.data;

        if (callback) callback();
      });
    }
  }
}
