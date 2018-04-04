$(document).on('turbolinks:load', function() {

  $('.open-other-statements').click(function(e) {
    e.preventDefault();
    $('.other-statements').toggle();
  });

  $('#people-filter li').click(function() {
      $('#people-filter li').removeClass('active');
      $(this).addClass('active');
  });
});
