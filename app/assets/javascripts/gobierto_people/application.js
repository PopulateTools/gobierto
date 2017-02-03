//= require ./app/init
//= require_tree ./app

$(document).on('turbolinks:load', function() {

  $('.open-other-statements').click(function(e) {
    e.preventDefault();
    $('.other-statements').toggle();
  }); 

});
