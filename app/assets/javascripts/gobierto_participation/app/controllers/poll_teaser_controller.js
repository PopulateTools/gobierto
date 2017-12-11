this.GobiertoParticipation.PollTeaserController = (function() {

  function PollTeaserController() {}

  PollTeaserController.prototype.show = function(){
    _refreshAnswers();
  };

  function _refreshAnswers() {
    $(document).ready(function() {
        var submit = $("#new_poll a");
        var selected = [];

        $('input[type=radio][name=radio]').change(function() {
            selected.push($('input[name=radio]:checked').val());
            var newUrl = submit.attr('href').split("?")[0] + "?answers=" + selected;
            submit.attr('href', newUrl);
        });

        $('.questions :checkbox').change(function() {
            selected.push($(this).val());
            var newUrl = submit.attr('href').split("?")[0] + "?answers=" + selected;
            submit.attr('href', newUrl);
        });
    });
  }

  return PollTeaserController;
})();

this.GobiertoParticipation.poll_teaser_controller = new GobiertoParticipation.PollTeaserController;
