//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require jquery.magnific-popup.min
//= require ./vendor/jquery-ui
//= require ./vendor/sticky-kit.min
//= require ./vendor/html5sortable
//= require air-datepicker/datepicker.min
//= require air-datepicker/i18n/datepicker.es
//= require module-admin
//= require ./app/init
//= require_tree ./app

$(document).on('turbolinks:load', function() {

  // Tabs navigation
  $('[data-tab-target]').on('click', function(e){
    e.preventDefault();
    var target = $(this).data('tab-target');
    $('[data-tab-target]').parent().removeClass('active');
    $('[data-tab-target="' + target + '"]').parent().addClass('active');

    $('[data-tab]').removeClass('active');
    $('[data-tab="' + target + '"]').addClass('active');
  });

  // Triangle indication
  $('.sub_filter li').on('click', function(e){
    e.preventDefault();
    $(this).siblings().removeClass('active');
    $(this).addClass('active');
  });

  // Modals
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

  $('.close_modal').click(function(e) {
    $.magnificPopup.close();
  });

  // Datepicker
  $('.air-datepicker').datepicker({
    autoClose: true
  });

});
