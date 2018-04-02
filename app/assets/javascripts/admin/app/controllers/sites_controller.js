this.GobiertoAdmin.SitesController = (function() {
  function SitesController() {}

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
      if(site_modules_with_root_path.includes($(this).val())){
        selectedModules.push($(this).val());
      }
    });

    selectedModules.push("GobiertoCms");

    var selected = $('#site_home_page').val();
    $('#site_home_page').empty();
    for (var i=0; i<selectedModules.length; i++){
       $('<option/>').val(selectedModules[i]).html(selectedModules[i]).appendTo('#site_home_page');
    }
    if(selected){
      $('#site_home_page').val(selected);
    }

    selectHomePageItem();
  }

  function selectHomePageItem() {
    if($('#site_home_page').val() == "GobiertoCms") {
      $('#home_page_item').show();
    } else {
      $('#home_page_item').hide();
    }
  }

  SitesController.prototype.edit = function(site_modules_with_root_path) {
    _homePage(site_modules_with_root_path);
  };

  return SitesController;
})();

this.GobiertoAdmin.sites_controller = new GobiertoAdmin.SitesController;
