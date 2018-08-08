function currentLocationMatches(action_path) {
  return $("body.gobierto_participation_" + action_path).length > 0
}

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

  if (currentLocationMatches("processes_contribution_containers_show")) {
    window.GobiertoParticipation.contribution_containers_controller.show(contributionContainerData);
  } else if (currentLocationMatches("processes_poll_answers_new")) {
    window.GobiertoParticipation.process_polls_controller.show();
  } else if (currentLocationMatches("processes_show")) {
    window.GobiertoParticipation.processes_controller.show();
  }

  // fix this to be only in the home
  window.GobiertoParticipation.poll_teaser_controller.show();
});
