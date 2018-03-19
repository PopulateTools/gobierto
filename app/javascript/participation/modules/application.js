$(document).on('turbolinks:load', function() {

  // Toggle description for Process#show stages diagram
  $('.toggle_description').click(function() {
    $(this).parents('.timeline_row').toggleClass('toggled');

    $(this).find('.fa').toggleClass('fa-caret-right fa-caret-down');
    $(this).siblings('.description').toggle();
  });

  $.fn.extend({
    toggleText: function(a, b){
      return this.text(this.text() == b ? a : b);
    }
  });

  // Animation for attending event button
  $('.attend_event').click(function() {
    $(this).find('.fa').toggleClass('hidden');
    $(this).toggleClass('checked');

    // Swap text
    $(this).find('span').toggleText('Quiero asistir', 'Asistirás');
  });

  $('.button_toggle').on('click', function() {
    $('.button.hidden').toggleClass('hidden');
  })

});
