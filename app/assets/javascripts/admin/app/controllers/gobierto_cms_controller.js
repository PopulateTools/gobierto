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
      $("#page_section").append('<option value="0">(Nueva sección)</option>');

      // parent
      $('.level_2').show();

      $('#page_parent').empty();
      populateParent($('#page_section').val());
    });

    $('#page_section').change(function(e){
      e.preventDefault();

      var section = $(this).val();

      if(section == 0) {
        $('.level_2').hide();

        // open the new ajax popup
        $.magnificPopup.open({
          closeOnBgClick: false,
          closeBtnInside: true,
          enableEscapeKey: true,
          removalDelay: 65,
          mainClass: 'mfp-fade',
          items: {
          },
          callbacks: {

          },
          type: 'ajax',
          ajax: {
            settings: {
              url: '/admin/cms/sections/new',
              type: 'GET'
            }
          }
        });
      } else {
        $('.level_2').show();
        $('#page_parent').empty();
        populateParent(section);
      }
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
