this.GobiertoAdmin.GobiertoCmsController = (function() {
  function GobiertoCmsController() {}

  GobiertoCmsController.prototype.edit = function() {
    _sections();
  };

  function _sections() {
    console.log("HOLA");

    $('.open_level_1').on('click', function(e){
      e.preventDefault();

      // Sections
      $('.level_1').show();
    });

    $('#page_section').change(function(e){
      e.preventDefault();

      // Do whatever you want to do when the select changes
      var parentId = $(this).val();
      //alert('You selected option ' + parentId);

      // Remove selects with
      $(".level_2").remove();


      // Get children
      $.getJSON(
          '/admin/cms/sections/' + parentId + '/section_items/',
          function(data) {

            var i, theContainer, theSelect, theOptions, numOptions, anOption;
            theOptions = data['section_items'];

            if(theOptions.length >= 1){
              // Create the container <div>
              theContainer = document.createElement('div');
              theContainer.className = "form_item select_control select_compact level_2 open_level_3";

              // Create the <select>
              theSelect = document.createElement('select');

              // Give the <select> some attributes

              theSelect.name =  parentId;
              theSelect.id =  parentId;

              // Add some <option>s
              numOptions = theOptions.length;
              for (i = 0; i < numOptions; i++) {
                  anOption = document.createElement('option');
                  anOption.value = theOptions[i]['id'];
                  anOption.innerHTML = theOptions[i]['name'];
                  theSelect.appendChild(anOption);
              }

              // Add the <div> to the DOM, then add the <select> to the <div>
              document.getElementById("section").appendChild(theContainer);
              theContainer.appendChild(theSelect);
            }
          }
      );

    });
  }
  return GobiertoCmsController;
})();

this.GobiertoAdmin.gobierto_cms_controller = new GobiertoAdmin.GobiertoCmsController;
