import "webpack-jquery-ui/slider";

$(document).on("turbolinks:load", function() {
  const rangeSliders = document.querySelectorAll(".js-range-slider");

  rangeSliders.forEach(slider => {
    const { min = 0, max = 100, default: defaultRange = [0, 100] } = slider.dataset;

    $(slider).slider({
      range: true,
      min: parseFloat(min),
      max: parseFloat(max),
      values: JSON.parse(defaultRange)
    });
  });
});
