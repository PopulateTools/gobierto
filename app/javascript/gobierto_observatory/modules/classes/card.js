import { json } from "d3-fetch";

export class Card {
  constructor(divClass) {
    this.container = divClass;
    this.tbiToken = window.populateData.token;
    this.div = $(this.container);
    this.trend = this.div.attr("data-trend");
    this.freq = this.div.attr("data-freq");
  }

  handlePromise(url, opts = {}) {
    return json(url, {
      headers: new Headers({ authorization: "Bearer " + this.tbiToken }),
      ...opts
    });
  }

  render() {
    this.getData();
  }
}
