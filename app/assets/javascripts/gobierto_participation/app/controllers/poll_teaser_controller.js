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
            selected = [];
            selected.push($('input[name=radio]:checked').val());
            var newUrl = submit.attr('href').split("?")[0] + "?answers=" + selected;
            submit.attr('href', newUrl);

            if (selected.length >= 1) {
              submit.removeClass("hidden");
            } else {
              submit.addClass("hidden");
            }
        });

        $('.questions :checkbox').change(function() {
            selected = $("input:checked").map(function() {return this.value}).get().join(',');
            var newUrl = submit.attr('href').split("?")[0] + "?answers=" + selected;
            submit.attr('href', newUrl);

            if ($("input:checked").length >= 1) {
              submit.removeClass("hidden");
            } else {
              submit.addClass("hidden");
            }
        });
    });
  }

  return PollTeaserController;
})();

this.GobiertoParticipation.poll_teaser_controller = new GobiertoParticipation.PollTeaserController;
