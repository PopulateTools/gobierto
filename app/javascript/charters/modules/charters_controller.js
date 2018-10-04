import { Sparkline } from 'visualizations'

window.GobiertoCharters.ChartersController = (function() {

  function ChartersController() {}

  ChartersController.prototype.show = function(){

    // DEBUG: MOCK DATA
    let data = [{"id":0,"data":[{"date":"2017-08-02T08:33:44.000Z","value":45},{"date":"2017-09-10T09:37:25","value":96},{"date":"2018-07-27T06:48:43","value":56}]},{"id":1,"data":[{"date":"2015-04-29T01:07:00","value":48},{"date":"2018-04-18T05:00:58","value":43},{"date":"2017-02-23T12:14:55","value":86}]},{"id":2,"data":[{"date":"2014-11-21T11:18:43","value":65},{"date":"2018-09-14T07:58:10","value":4},{"date":"2015-12-24T10:38:48","value":73}]},{"id":3,"data":[{"date":"2014-01-24T02:10:42","value":35},{"date":"2015-05-30T09:34:02","value":92},{"date":"2016-11-25T06:38:13","value":20}]},{"id":4,"data":[{"date":"2017-10-25T04:55:16","value":11},{"date":"2015-06-18T10:29:43","value":91},{"date":"2016-11-11T01:58:55","value":84}]},{"id":5,"data":[{"date":"2015-03-16T10:34:55","value":98},{"date":"2016-04-27T06:13:45","value":47},{"date":"2016-10-15T02:16:56","value":18}]},{"id":6,"data":[{"date":"2015-11-02T12:41:31","value":33},{"date":"2017-09-21T02:12:15","value":27},{"date":"2018-08-26T03:44:34","value":3}]},{"id":7,"data":[{"date":"2018-01-19T08:56:23","value":95},{"date":"2018-04-04T03:49:19","value":94},{"date":"2016-03-31T11:55:23","value":85}]},{"id":8,"data":[{"date":"2017-01-17T11:12:04","value":59},{"date":"2016-01-22T12:39:44","value":54},{"date":"2015-05-30T11:35:25","value":67}]},{"id":9,"data":[{"date":"2014-08-14T05:54:31","value":83},{"date":"2017-01-02T05:59:22","value":39},{"date":"2016-01-11T10:26:26","value":17}]}]

    // prepare the DATA
    data.forEach(chart => chart.data.forEach(d => {
      d.date = new Date(d.date).getFullYear()
    }))

    const $sparklines = $('.sparkline')

    $sparklines.each((i, container) => {
      var chart = new Sparkline(container.id, data[i].data)
      chart.render()
    })
  };

  return ChartersController;
})();

window.GobiertoCharters.charters_controller = new GobiertoCharters.ChartersController;
