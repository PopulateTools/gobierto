// import 'babel-polyfill'

window.GobiertoAdmin.GobiertoCmsController = (function() {
  function GobiertoCmsController() {}

  GobiertoCmsController.prototype.edit = function(sectionId, parentId, sectionItemId) {
    _sections(sectionId, parentId, sectionItemId);

    if(sectionId != "null") {
      $("#permission_1").prop("checked", true)
      $('.open_level_1').trigger('change');
      $('#page_section').val(sectionId);
    }
  };

  GobiertoCmsController.prototype.loadSections = function(sectionSelected) {
    _populateSection(sectionSelected);
    $('#page_parent').empty();
    $('.level_2').show();
    populateParent(sectionSelected, null);
  };

  function _sections(sectionId, parentId, sectionItemId) {
    var $level1 = $('.level_1');
    var $level2 = $('.level_2');
    var $section = $('#page_section');
    var $parent = $('#page_parent');

    $('.open_level_1').on('change', function(e){
      e.preventDefault();

      if($("#permission_1").prop('checked'))
        if(sectionId != "null") {
          getSections(sectionId)
          $level1.show();
          $level2.show();
          populateParent(sectionId, parentId, sectionItemId);

        } else {
          // Sections
          $level1.show();
          getSections(sectionId)
          // parent
          if($section.val() == "") {
            $level2.hide();
          } else {
            $parent.empty();
            $level2.show();
            populateParent(sectionId, parentId, sectionItemId);
          }
        }
        else {
          $section.val("");
          $level1.hide();
          $level2.hide();
          $parent.empty();
        }
    });

    $('#page_section').change(function(e){
      e.preventDefault();
      var section = $(this).val();

      if(section == "0") {
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
              type: 'GET',
              data: {
                'globalized-form-container': 'true'
              }
            }
          },
          callbacks: {
            ajaxContentAdded: function() {
              window.GobiertoAdmin.globalized_forms_component.handleGlobalizedForm();
            }
          }
        });
      } else if (section == "") {
        $level2.hide();
        $section.removeAttr("selected");
        $parent.removeAttr("selected");
      } else {
        $level2.show();
        $parent.empty();
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

  function appendSections(sections, sectionSelected) {
    var $section = $('#page_section');

    $section.empty();
    var numOptions = sections.length;
    var anOption;
    $section.prepend("<option value='' selected='selected'></option>");
    for (var i = 0; i < numOptions; i++) {
      anOption = document.createElement('option');
      anOption.value = sections[i]['id'];
      anOption.innerHTML = sections[i]['title'];

      $section.append(anOption);
    }
    $section.append('<option value="0">' + I18n.t('gobierto_admin.gobierto_cms.pages.form.new_section') + '</option>');

    if ("null" != sectionSelected) {
      $section.val(sectionSelected);
    } else {
      $section.val($("#page_section option:first").val());
    }
  }

  function populateParent(section, parentId, sectionItemId) {
    var $parent = $('#page_parent')

    if(!(section=="null")) {

      // Get children
      $.getJSON(
        '/admin/cms/sections/' + section + '/section_items/',
        function(data) {
          var theOptions;
          theOptions = data['section_items'];

          $parent.append('<option value="0">' + I18n.t('gobierto_admin.gobierto_cms.pages.form.without_parent') + '</option>');

          if(theOptions.length >= 1){
            // Create the container <div>
            appendParents($parent, theOptions, 0);

            if (typeof parentId != "undefined" && parentId != "null") {
              $parent.val(parentId);
              $('#page_parent option[value="' + sectionItemId + '"]').attr("disabled","disabled");
            } else {
              $parent.val($("#page_parent option:first").val());
              if (typeof parentId != "undefined" && parentId != "null") {
                $("#page_parent option:last").attr("disabled","disabled");
              }
            }
          }
        }
      );
    }
  }

  function appendParents(parent, nodes, level) {
    var anOption;
    // Add some <option>s
    for (var i in nodes) {
      anOption = document.createElement('option');
      anOption.value = nodes[i]['id'];
      anOption.innerHTML = "-".repeat(level) + " " + nodes[i]['name'];
      parent.append(anOption);
      if(nodes[i] && nodes[i].children && nodes[i].children.length >= 1) {
        appendParents(parent, nodes[i].children, level + 1)
      }
    }
  }

  return GobiertoCmsController;
})();

window.GobiertoAdmin.gobierto_cms_controller = new GobiertoAdmin.GobiertoCmsController;
