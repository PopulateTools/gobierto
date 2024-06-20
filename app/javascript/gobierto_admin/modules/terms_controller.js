import Sortable from 'sortablejs';

window.GobiertoAdmin.TermsController = (function() {
  function TermsController() {}

  TermsController.prototype.index = function() {
    _handleTermsList();
    _handleSortableList();
  };

  function _handleTermsList() {
    // Toggle selected element child
    $('.v_container .v_el .icon-caret').click(function(e) {
      e.preventDefault();

      // ToDo: Don't relay on icon specific names
      if ($(this).is('.fa-caret-right')) {
        $(this).removeClass('fa-caret-right');
        $(this).addClass('fa-caret-down');
      }
      else {
        $(this).removeClass('fa-caret-down');
        $(this).addClass('fa-caret-right');
      }

      $(this).parent().parent().parent().parent().find('> .list-group > .v_el').toggleClass('el-opened');

    });

    // Close all elements except first level
    $('.v_container .v_heading .fa-caret-square-right').click(function(e) {
      e.preventDefault();
      // closes all elements
      $('.v_container .v_el_level .v_el').removeClass('el-opened');
      $('.fa-caret-down').removeClass('fa-caret-down').addClass('fa-caret-right');
    });

    // Open all elements except first level
    $('.v_container .v_heading .fa-caret-square-down').click(function(e) {
      e.preventDefault();
      // Opens all elements
      $('.v_container .v_el_level .v_el').addClass('el-opened');
      $('.fa-caret-right').removeClass('fa-caret-right').addClass('fa-caret-down');
    });

    // show only action buttons (edit, delete) when hovering an item
    // ToDo: Control that only elements for the item are shown, not for it's parents
    $('.v_el').hover(
      function(e) {
        $(this).first('.v_el_actions').addClass('v_el_active');
      },
      function(e) {
        $(this).first('.v_el_actions').removeClass('v_el_active');
      }
    );
  }

  function _handleSortableList() {
    var nestedSortables = [].slice.call(document.querySelectorAll('.list-group'));

    // Loop through each nested sortable element
    for (let i = 0; i < nestedSortables.length; i++) {
      Sortable.create(nestedSortables[i], {
        animation: 150,
        fallbackOnBody: true,
        swapThreshold: 0.65,
        onEnd: function (e) {
          $(e.item).addClass('el-opened');
          let idsTree = {};
          $('.list-group').children().each((index, node) => {
            idsTree[index] = { id: node.dataset.id, position: index, class: node.dataset.class };
          });
          _requestUpdate('[data-behavior="sortable"]', idsTree);
        }
      });
    }
  }

  function _refreshCalculations(wrapper) {
    $.ajax({
      url: $(wrapper).data("calculated-values-target"),
      dataType: 'json',
      success: function(values) {
        for (let id in values) {
          for (let key in values[id]) {
            $(`.v_el_decorated.values#${id}`).find(`div.${key}`).html(values[id][key]);
          }
        }
      }
    });
  }

  function _requestUpdate(wrapper, positions) {
    $.ajax({
      url: $(wrapper).data("sortable-target"),
      method: "POST",
      data: { positions: positions },
      success: function() {
        _refreshCalculations('[data-behavior="calculated-values"]');
      }
    });
  }

  TermsController.prototype.form = function() {
    _handleTermsSelectBehaviors()
  }

  function _handleTermsSelectBehaviors() {
    $("select#term_term_id").select2()

    // This should be controlled via css
    $(".select2-container").css("padding-top", "22px");
  }

  return TermsController;
})();

window.GobiertoAdmin.terms_controller = new GobiertoAdmin.TermsController;
