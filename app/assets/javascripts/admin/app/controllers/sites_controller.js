this.GobiertoAdmin.SitesController = (function() {
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
            $(municipalityFieldHandler).val('');
            response(data["suggestions"])
          },
        });
      },
      select: function(event, ui) {
        $(municipalityFieldHandler).val(ui.item.data.municipality_id);
      },
      minLength: 3
    }

    $.ui.autocomplete(autocompleteOptions, $(locationFieldHandler));
  }

  function _homePage(site_modules_with_root_path) {
    $(document).ready(function() {
        populateHomePage(site_modules_with_root_path);
    });

    $("input[name='site[site_modules][]']").on('click', function() {
      populateHomePage(site_modules_with_root_path);
    });
  }

  function populateHomePage(site_modules_with_root_path) {
    var selectedModules = [];
    $.each($("input[name='site[site_modules][]']:checked"), function(){
      if(site_modules_with_root_path.includes($(this).val())){
        selectedModules.push($(this).val());
      }
    });

    var selected = $('#site_home_page').val();
    $('#site_home_page').empty();
    for (var i=0; i<selectedModules.length; i++){
       $('<option/>').val(selectedModules[i]).html(selectedModules[i]).appendTo('#site_home_page');
    }
    if(selected){
      $('#site_home_page').val(selected);
    }
  }


  SitesController.prototype.edit = function(api_token, site_modules_with_root_path) {
    _handleSiteLocationAutocomplete(api_token);
    _homePage(site_modules_with_root_path);
  };

  return SitesController;
})();

this.GobiertoAdmin.sites_controller = new GobiertoAdmin.SitesController;
