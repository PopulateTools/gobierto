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

$(document).on("ajax:complete ajaxSuccess", function() {
  $('.open_remote_modal').magnificPopup({
    type: 'ajax',
    removalDelay: 300,
    mainClass: 'mfp-fade'
  });

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

  $('.open_remote_modal').magnificPopup({
    type: 'ajax',
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
});
