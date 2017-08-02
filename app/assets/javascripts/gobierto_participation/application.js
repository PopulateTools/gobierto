//= require algolia/v3/algoliasearch.min
//= require ./app/init
//= require_tree ./app

$(document).on('turbolinks:load', function() {

  // Toggle description for Process#show stages diagram
  $('.toggle_description').click(function() {
    $(this).parents('.timeline_row').toggleClass('toggled');

    $(this).find('.fa').toggleClass('fa-caret-right fa-caret-down');
    $(this).siblings('.description').toggle();
  });

});
