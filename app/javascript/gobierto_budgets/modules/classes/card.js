export class Card {
  constructor(divClass, current_year) {
    this.container = divClass;
    this.currentYear = (current_year !== undefined) ? parseInt(current_year) : null;
    this.tbiToken = window.populateData.token;
  }

  render() {
    this.getData();
  }
}
