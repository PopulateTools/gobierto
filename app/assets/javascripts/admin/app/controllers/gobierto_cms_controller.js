this.GobiertoAdmin.GobiertoCmsController = (function() {
  function GobiertoCmsController() {}

  GobiertoCmsController.prototype.edit = function() {
    _sections();
  };

  function _sections() {
    $('.open_level_1').on('click', function(e){
      e.preventDefault();

      // Sections
      $('.level_1').show();

      // parent
      $('.level_2').show();

      $('#page_parent').empty();
      populateParent($('#page_section').val());
    });

    $('#page_section').change(function(e){
      e.preventDefault();

      $('#page_parent').empty();
      var section = $(this).val();
      populateParent(section);
    });
  }

  function populateParent(section) {
    // Get children
    $.getJSON(
        '/admin/cms/sections/' + section + '/section_items/',
        function(data) {
          var i, theContainer, theSelect, theOptions, numOptions, anOption;
          theOptions = data['section_items'];

          $("#page_parent").append('<option value="0">(sin padre)</option>');

          if(theOptions.length >= 1){
            // Create the container <div>
            appendSectionItems(theOptions, 0);
          }
        }
    );
  }

  function appendSectionItems(nodes, level) {
    // Add some <option>s
    numOptions = nodes.length;
    for (i = 0; i < numOptions; i++) {
        anOption = document.createElement('option');
        anOption.value = nodes[i]['id'];
        anOption.innerHTML = ("-".repeat(level)) + " " + nodes[i]['name'];

        $("#page_parent").append(anOption);
        if(nodes[i].children.length >= 1) {
          level += 1
          appendSectionItems(nodes[i].children, level)
        }
    }
  }

  return GobiertoCmsController;
})();

this.GobiertoAdmin.gobierto_cms_controller = new GobiertoAdmin.GobiertoCmsController;
