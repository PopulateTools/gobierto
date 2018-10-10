import 'mailcheck'

window.User.RegistrationController = (function() {
  function RegistrationController() {}

  RegistrationController.prototype.new = function(){
    _setupMailcheck();
  };

  function _setupMailcheck(){
    var domains = ["aol.com", "yahoo.com", "yahoo.es", "google.com", "gmail.com", "me.com", "live.com", "live.es", "googlemail.com", "msn.com", "hotmail.com", "hotmail.co.es", "hotmail.com.es", "hotmail.es", "yahoo.co.es", "facebook.com", "outlook.com", "outlook.es", "icloud.com", "telefonica.es", "yandex.com"];
    var topLevelDomains = ["com", "org", "net", "int", "edu", "gov", "mil", "es", "cat", "com.es", "com.cat", "tools"];

    $("#user_registration_email").on("keyup", function() {
      $(this).mailcheck({
        domains: domains,
        topLevelDomains: topLevelDomains,
        suggested: function(element, suggestion) {
          $("#email-suggestion").remove();
          if (element.val().includes("@")) {
            $("#user_registration_email").after("<span id=\"email-suggestion\">" + I18n.t("layouts.mailcheck.suggestion_message") + " <b><i>" + suggestion.full + "</i></b>?</span>");
          }
        },
        empty: function() {
          $("#email-suggestion").remove();
        }
      });
    });

  }

  return RegistrationController;
})();

window.User.registration_controller = new User.RegistrationController;
