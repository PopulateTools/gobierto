//= require algolia/v3/algoliasearch.min
//= require fullcalendar
//= require ./app/init
//= require_tree ./app

$(document).on('turbolinks:load', function() {

  $('.open-other-statements').click(function(e) {
    e.preventDefault();
    $('.other-statements').toggle();
  });

  $('#people-filter li').click(function(e) {
      $('#people-filter li').removeClass('active');
      $(this).addClass('active');
  });
});
