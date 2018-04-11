window.GobiertoParticipation.PollTeaserController = (function() {

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

            var url = refreshLinkButton(selected, submit.attr('href'));
            submit.attr('href', url);

            if (selected.length >= 1) {
              submit.removeClass("hidden");
            } else {
              submit.addClass("hidden");
            }
        });

        $('.questions :checkbox').change(function() {
            selected = $("input:checked").map(function() {return this.value}).get().join(',');

            var url = refreshLinkButton(selected, submit.attr('href'));
            submit.attr('href', url);

            if ($("input:checked").length >= 1) {
              submit.removeClass("hidden");
            } else {
              submit.addClass("hidden");
            }
        });
    });
  }

  function refreshLinkButton(selected, url) {
    var newUrl = url.split("?")[0] + "?answers=" + selected;

    if (newUrl.includes("/user/sessions/new")) {
      newUrl += "&" + "open_modal=true";
    }

    return newUrl
  }

  return PollTeaserController;
})();

window.GobiertoParticipation.poll_teaser_controller = new GobiertoParticipation.PollTeaserController;
