import { Sparkline } from 'lib/visualizations'

window.GobiertoCharters.ChartersController = (function() {

  function ChartersController() {}

  ChartersController.prototype.show = function(){

    // DEBUG: Esta funcion DEBE ser eliminada cuando se obtengan datos verdaderos
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
      let options = {
        axes: true,
        aspectRatio: 3,
        margins: {
          top: 0,
          bottom: 0,
          left: 0,
          right: 0
        }
      }

      let chart = new Sparkline(`#${container.id}`, mock(7), options)
      chart.render()
    })
  };

  return ChartersController;
})();

window.GobiertoCharters.charters_controller = new GobiertoCharters.ChartersController;
