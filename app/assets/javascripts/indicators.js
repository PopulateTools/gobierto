$(document).on('turbolinks:load', function() {
  var vis_agedb = [];

  if ($('#age_distribution').length > 0) {
    var vis = new VisAgeDistribution('#age_distribution', 39075, 2015);
    vis.render();
    vis_agedb.push(vis);
  }
});
