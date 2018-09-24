import 'magnific-popup'
import 'tipsy-1a'

// Global util functions
export function isDesktop(){
  return $(window).width() > 740;
}

export function isMobile() {
  return !isDesktop();
}

/* Toggle text method */
$.fn.extend({
  toggleText: function(a, b){
    return this.text(this.text() == b ? a : b);
  }
});

$(document).on('turbolinks:load ajax:complete ajaxSuccess', function() {
  $('.open_remote_modal').magnificPopup({
    type: 'ajax',
    removalDelay: 300,
    mainClass: 'mfp-fade',
    callbacks: {
      ajaxContentAdded: function() {
        if (window.GobiertoAdmin.process_stages_controller) {
          window.GobiertoAdmin.process_stages_controller.form();
        }
        if (window.GobiertoAdmin.globalized_forms_component) {
          window.GobiertoAdmin.globalized_forms_component.handleGlobalizedForm();
        }
        if (window.GobiertoAdmin.gobierto_citizens_charters_editions_intervals_controller) {
          window.GobiertoAdmin.gobierto_citizens_charters_editions_intervals_controller.handleForm();
        }
      }
    }
  });
});

$(document).on('ajax:complete ajaxSuccess', function() {
  $('.tipsit').tipsy({fade: false, gravity: 's', html: true});
  $('.tipsit-n').tipsy({fade: false, gravity: 'n', html: true});
  $('.tipsit-w').tipsy({fade: false, gravity: 'w', html: true});
  $('.tipsit-e').tipsy({fade: false, gravity: 'e', html: true});
  $('.tipsit-treemap').tipsy({fade: false, gravity: $.fn.tipsy.autoNS, html: true});
});

$(document).on('turbolinks:load', function() {

  // Include here common callbacks and behaviours

  // Tabs navigation
  $('[data-tab-target]').on('click', function(e){
    e.preventDefault();
    var target = $(this).data('tab-target');
    var scope = $('[data-tab-scope]').length ? $(this).closest('[data-tab-scope]') : $('body');

    scope.find('[data-tab-target]').parent().removeClass('active');
    scope.find('[data-tab-target="' + target + '"]').parent().addClass('active');
    scope.find('[data-tab]').removeClass('active');
    scope.find('[data-tab="' + target + '"]').addClass('active');
  });

  // Modal windows
  $('.open_modal').magnificPopup({
    type: 'inline',
    removalDelay: 300,
    mainClass: 'mfp-fade'
  });

  $('.close_modal').click(function() {
    $.magnificPopup.close();
  });

  function toggleTarget($this){
    var $target = $('[data-toggle-target="'+$this.data('toggle')+'"]');
    $this.is(':checked') ? $target.show() : $target.hide();
  }

  $('[data-toggle-target]').hide();
  $('[data-toggle]').each(function(){ toggleTarget($(this)) });
  $('[data-toggle]').click(function(){ toggleTarget($(this)) });

  // js-disabled elements
  $('.js-disabled').click(function(e) {
    e.preventDefault();
  });

  // js-dropdown
  $('.js-dropdown').on('click', function(){

    /*
      HOW TO USE JS-DROPDOWN

      <div>
        <button class="js-dropdown" data-dropdown="NAME"></button>
        <div class="hidden" data-dropdown="NAME"></div>
      </div>

      - Notice that NAME property must be equal both trigger and contents
      - Add 'js-dropdown' class to the trigger (button tag or whatever) and 'hidden' to the contents
    */

    const dropdownname = $(this).data('dropdown');
    const $content = $('[data-dropdown="' + dropdownname + '"]:not(.js-dropdown)')

    $content.toggleClass('hidden');
    $content.parent().css('position', 'relative');
  });
});
