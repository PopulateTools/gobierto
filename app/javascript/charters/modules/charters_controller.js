import { Sparkline } from 'visualizations'

window.GobiertoCharters.ChartersController = (function() {

  function ChartersController() {}

  ChartersController.prototype.show = function(){

    // DEBUG: MOCK DATA
    function mock(length = 2) {
      let json = [];
      for (var i = 0; i < length; i++) {
        json.push({
          date: new Date().getFullYear() - i,
          value: Math.floor(Math.random() * Math.floor(100))
        })
      }
      return json
    }

    const $sparklines = $('.sparkline')

    $sparklines.each((i, container) => {
      var chart = new Sparkline(`#${container.id}`, mock(5))
      chart.render()
    })
  };

  return ChartersController;
})();

window.GobiertoCharters.charters_controller = new GobiertoCharters.ChartersController;
