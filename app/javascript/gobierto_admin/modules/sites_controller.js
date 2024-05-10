import 'select2'

window.GobiertoAdmin.SitesController = (function() {
  function SitesController() {}

  function _handleSiteLocationAutocomplete(municipalities_suggestion_url) {
    var locationFieldHandler = "#site_organization_name";
    var municipalityFieldHandler = "#site_organization_id";
    var autocompleteOptions = {
      source: function(request, response) {
        $.ajax({
          url: municipalities_suggestion_url,
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
      $("select#site_home_page_item_id").select2({
        width: '100%'
      });
    });

    $("input[name='site[site_modules][]']").on('click', function() {
      populateHomePage(site_modules_with_root_path);
    });

    $('#site_home_page').on('change', function(e){
      e.preventDefault();
      selectHomePageItem();
    });
  }

  function populateHomePage(site_modules_with_root_path) {
    var selectedModules = [];
    $.each($("input[name='site[site_modules][]']:checked"), function(){
      if (site_modules_with_root_path.includes($(this).val())){
        selectedModules.push($(this).val());
      }
    });

    selectedModules.push("GobiertoCms");

    var selected = $('#site_home_page').val();
    $('#site_home_page').empty();
    for (var i=0; i<selectedModules.length; i++){
       $('<option/>').val(selectedModules[i]).html(selectedModules[i]).appendTo('#site_home_page');
    }
    if (selected){
      $('#site_home_page').val(selected);
    }

    selectHomePageItem();
  }

  function selectHomePageItem() {
    if ($('#site_home_page').val() == "GobiertoCms") {
      $('#home_page_item').show();
    } else {
      $('#home_page_item').hide();
    }
  }

  SitesController.prototype.edit = function(options) {
    _handleSiteLocationAutocomplete(options.municipalities_suggestion_url);
    _homePage(options.site_modules_with_root_path);
  };

  return SitesController;
})();

window.GobiertoAdmin.sites_controller = new GobiertoAdmin.SitesController;
