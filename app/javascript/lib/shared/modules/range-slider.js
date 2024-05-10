// https://api.jqueryui.com/slider/
export class RangeSlider {
  constructor({ elem, min = 0, max = 100, defaultRange = [min, max], rangeCallback = () => {} }) {
    this.element = elem || undefined;

    if (this.element) {
      $(this.element).slider({
        range: true,
        min,
        max,
        values: defaultRange,
        slide: rangeCallback
      });
    }
  }

  destroy() {
    $(this.element).slider("destroy")
  }
}
