export class Card {
  constructor(divClass) {
    this.container = divClass
    this.tbiToken = window.populateData.token
    this.div = $(this.container)
    this.trend = this.div.attr('data-trend')
    this.freq = this.div.attr('data-freq')
  }

  render() {
    this.getData()
  }
}
