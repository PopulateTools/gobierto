import { json } from "d3-fetch";

export class Card {
  constructor(divClass, current_year) {
    this.container = divClass;
    this.currentYear =
      current_year !== undefined ? parseInt(current_year) : null;
    this.tbiToken = window.populateData.token;
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
