this.App.SitesController = (function() {
  function SitesController() {}

  function _handleSiteLocationAutocomplete(api_token) {
    var locationFieldHandler = "#site_location_name";
    var municipalityFieldHandler = "#site_municipality_id";
    var autocompleteOptions = {
      source: function(request, response) {
        var element = $(this)[0].element;
        $.ajax({
          url: element.data("autocompleteUrl"),
          headers: { "authorization": "Bearer " + api_token },
          crossDomain: true,
          dataType: "json",
          method: "GET",
          data: { query: request.term },
          success: function(data) {
            response(data["suggestions"])
          },
        });
      },
      select: function(event, ui) {
        $(municipalityFieldHandler).val(ui.item.data.municipality_id);
      },
      minLength: 3
    }

    $(locationFieldHandler).autocomplete(autocompleteOptions);
  }

  SitesController.prototype.edit = function(api_token) {
    _handleSiteLocationAutocomplete(api_token);
  };

  return SitesController;
})();

this.App.sites_controller = new App.SitesController;
