function currentLocationMatches(action_path) {
  return $("body.gobierto_budget_consultations_" + action_path).length > 0
}

$(document).on('turbolinks:load', function() {
  if (currentLocationMatches("consultations_consultation_responses_new")) {
    window.GobiertoBudgetConsultations.consultation_responses_controller.new();
  } else if (currentLocationMatches("consultations_consultation_items_index")) {
    window.GobiertoBudgetConsultations.consultation_items_controller.index(newConsultationResponsePath);
  }
});
