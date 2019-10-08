import "webpack-jquery-ui/slider";

export const rangeSlider = ({ elem, min = 0, max = 100, defaultRange = [min, max], rangeCallback = () => {} }) => {
  if (elem) {
    $(elem).slider({
      range: true,
      min,
      max,
      values: defaultRange,
      slide: rangeCallback
    });
  }
};
