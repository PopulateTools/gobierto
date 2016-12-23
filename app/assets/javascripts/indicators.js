$(document).on('turbolinks:load', function() {
  
  if ($('#age_distribution').length > 0) {
    window.ageDistribution = new VisAgeDistribution('#age_distribution', 39075, 2015);
    console.log("age_distribution")
  }

});
