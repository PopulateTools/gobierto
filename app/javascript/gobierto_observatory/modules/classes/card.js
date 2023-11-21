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

  _normalize(str) {
    var from =
        "1234567890ÃÀÁÄÂÈÉËÊÌÍÏÎÒÓÖÔÙÚÜÛãàáäâèéëêìíïîòóöôùúüûÑñÇç ‘/&().!,'",
      to = "izeasgtogoAAAAAEEEEIIIIOOOOUUUUaaaaaeeeeiiiioooouuuunncc_______",
      mapping = {};

    for (let i = 0, j = from.length; i < j; i++) {
      mapping[from.charAt(i)] = to.charAt(i);
    }

    var ret = [];
    for (let i = 0, j = str.length; i < j; i++) {
      var c = str.charAt(i);
      if (Object.prototype.hasOwnProperty.call(mapping, str.charAt(i))) {
        ret.push(mapping[c]);
      } else {
        ret.push(c);
      }
    }

    return ret.join("").toLowerCase();
  }
}
