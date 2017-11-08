this.GobiertoAdmin.GobiertoCmsController = (function() {
  function GobiertoCmsController() {}

  GobiertoCmsController.prototype.edit = function(sectionId, parentId) {
    _sections(sectionId, parentId);
  };

  GobiertoCmsController.prototype.loadSections = function(sectionSelected) {
    _populateSection(sectionSelected);
    $('#page_parent').empty();
    $('.level_2').show();
    populateParent(sectionSelected, null);
  };

  function _sections(sectionId, parentId) {
    $('.open_level_1').on('click', function(e){
      e.preventDefault();

      // Sections
      $('.level_1').show();
      getSections(sectionId)

      // parent
      $('.level_2').show();

      $('#page_parent').empty();


      populateParent($('#page_section').val(), parentId == "null" ? "0" : parentId);
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
          type: 'ajax',
          ajax: {
            settings: {
              url: '/admin/cms/sections/new?remote=true&from_page_widget=true',
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

  function _populateSection(sectionSelected) {
    // Get sections
    getSections(sectionSelected)
  }

  function getSections(sectionSelected) {
    // Get sections
    $.getJSON(
        '/admin/cms/sections',
        function(data) {
          appendSections(data['sections'], sectionSelected);
        }
    );
  }

  function populateParent(section, parentId) {
    // Get children
    $.getJSON(
        '/admin/cms/sections/' + section + '/section_items/',
        function(data) {
          var i, theContainer, theSelect, theOptions, numOptions, anOption;
          theOptions = data['section_items'];

          $("#page_parent").append('<option value="0">' + I18n.t('gobierto_admin.gobierto_cms.pages.form.without_parent') + '</option>');

          if(theOptions.length >= 1){
            // Create the container <div>
            appendSectionItems(theOptions, 0);
            $("#page_parent").val(parentId);
          }
        }
    );
  }

  function appendSections(sections, sectionSelected) {
    $('#page_section').empty();
    numOptions = sections.length;
    for (i = 0; i < numOptions; i++) {
        anOption = document.createElement('option');
        anOption.value = sections[i]['id'];
        anOption.innerHTML = sections[i]['title'];

        $("#page_section").append(anOption);
    }
    $("#page_section").append('<option value="0">' + I18n.t('gobierto_admin.gobierto_cms.pages.form.new_section') + '</option>');

    $("#page_section").val(sectionSelected);
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
