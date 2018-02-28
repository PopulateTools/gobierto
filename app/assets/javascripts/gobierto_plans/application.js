//= require ./app/init
//= require_tree ./app

$(document).on('turbolinks:load', function() {

  $('.bread_hover').hover(function(e) {
    $('.bread_links a').attr('aria-expanded', true);
    $('.line_browser').velocity("fadeIn", { duration: 50 });
  }, function(e) {
    $('.bread_links a').attr('aria-expanded', false);
    $('.line_browser').velocity("fadeOut", { duration: 50 });
  });

});
