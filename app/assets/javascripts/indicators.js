$(document).on('turbolinks:load', function() {
  var vis_agedb = [];
  var vis_unempl = [];

  if ($('#age_distribution').length > 0) {
    var vis = new VisAgeDistribution('#age_distribution', '39075', '2015');
    vis.render();
    vis_agedb.push(vis);
  }
  
  if ($('#unemployment_age').length > 0) {
    var vis = new VisUnemploymentAge('#unemployment_age', '39075', '2015');
    vis.render();
    vis_unempl.push(vis);
  }
});
