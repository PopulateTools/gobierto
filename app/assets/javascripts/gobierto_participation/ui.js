'use strict';

$(function(){

  if($(window).width() > 740) {
    function rebindAll() {
      $('.tipsit').tipsy({fade: true, gravity: 's'});
      $('.tipsit-n').tipsy({fade: true, gravity: 'n'});
      $('.tipsit-w').tipsy({fade: true, gravity: 'w'});
      $('.tipsit-e').tipsy({fade: true, gravity: 'e'});
    }
  }

  // init
  $('.dynatable').dynatable({
    inputs: {
      paginationPrev: 'Anterior',
      paginationNext: 'Siguiente',
      paginationGap: [1,2,2,1],
      perPageText: 'Mostrar: ',
      recordCountText: 'Mostrando ',
      processingText: 'Procesando...',
      searchText: 'Buscar:'
    },
    dataset: {
      perPageDefault: 25,
      perPageOptions: [25,50,100, 300]
    }
  });
  $(".sticky").sticky({topSpacing:0});
  $('.datepicker').pickadate({
    selectYears: true,
    selectMonths: true
  });
  $('.timepicker').pickatime();

  // TODO: Sandbox, remove me
  $('[data-consultation-type="open"]').click(function(e) {
    $('form#consultation_open').show();
    $('form#consultation_closed').hide();
  });
  $('[data-consultation-type="closed"]').click(function(e) {
    $('form#consultation_open').hide();
    $('form#consultation_closed').show();
  });

  $('[data-legal]').click(function(e) {
    e.preventDefault();
    var text = $(this).attr("data-legal");
    $('[data-legal-content="'+text+'"]').toggle();
  });

  $('[data-account="change_password"]').click(function(e) {
    e.preventDefault();
    $('.change_password_fields').slideToggle();
  });

  $(".form_item label *").focus(function() {
    $(this).parent().parent(".form_item").addClass('form_item_focused');
  }).focusout(function() {
    $(this).parent().parent(".form_item").removeClass('form_item_focused');
  });

  rebindAll(null);

  /**** WYSIWYG ********/
  // var editorSelector = '.editor';
  // if($(editorSelector).length > 0){
  //   window.editor = new Quill('.editor', {
  //     theme: 'snow',
  //     modules: {
  //       'toolbar': { container: '#full-toolbar' },
  //       'link-tooltip': true
  //     },
  //   });
  // }

  // $('.js-text-receiver').hide();
  // $('form').on('submit', function(e){
  //   if(window.editor !== undefined){
  //     $('.js-text-receiver').val(window.editor.getHTML());
  //   }
  // });
  /**** WYSIWYG ********/

  $('#gobierto_participation_consultation_kind_open_answers').on('change', function(e){
    if($(this).is(':checked')){
      $('[data-rel="closed-answers-only"]').hide();
    }
  });

  $('#gobierto_participation_consultation_kind_closed_answers').on('change', function(e){
    if($(this).is(':checked')){
      $('[data-rel="closed-answers-only"]').show();
    }
  });

  if($('#gobierto_participation_consultation_kind_closed_answers').is(':checked')){
    $('[data-rel="closed-answers-only"]').show();
  } else {
    $('[data-rel="closed-answers-only"]').hide();
  }

  function replaceOptionsNumbers(){
    var i = 1;
    $('.survey_option').each(function(position, e){
      $(this).find('span.position').text(i + ".");
      i++;
    });
  }
  replaceOptionsNumbers();

  $('[data-rel="closed-answers-only"]')
    .on('cocoon:after-insert', function(e, added_option) {
      replaceOptionsNumbers();
    })
    .on('cocoon:after-remove', function(e, removed_option) {
      replaceOptionsNumbers();
    });
  $('.photobooth_item .sidebar').css('min-height', $('.photobooth_item .main').height());
  $('.photobooth_home .photobooth_call').css('min-height', $('.photobooth_home .photobooth_photo').height()*2);
  $('.photobooth_photo').hover(function(e) {
    e.preventDefault();
    $(this).find('.title').velocity("fadeIn", { duration: 250 });
  }, function(e) {
    $(this).find('.title').velocity("fadeOut", { duration: 250 });
  });

  $('.sortable').nestedSortable({
    listType: 'ul',
    handle: 'div',
    items: 'li',
    toleranceElement: '> div'
  });

  $(".sortable").on("sortupdate", function(event, ui){
    var data = $('.sortable').nestedSortable('toArray');
    $.ajax({
      type: "PUT",
      url: "/admin/cms/pages/batch_update",
      data: { pages: data }
    });
  });

  $('#toggle-fileupload').on('click', function(e){
    e.preventDefault();
    $('.fileupload-container').show();
  });
  $('#progress').hide();
  $('.fileupload-container').hide();
  $('#fileupload').fileupload({
    url: $(this).data('url'),
    type: 'POST',
    dataType: 'html',
    done: function (e, data) {
      $('#progress').hide();
      $('#files').append(data.result);
      var attachment_id = $(data.result).data('id');
      $('#gobierto_cms_page_attachments_ids').val($('#gobierto_cms_page_attachments_ids').val() + ',' + attachment_id);

      $(".file[data-id='"+attachment_id+"']").hover(function() {
        $(this).find('.delete').toggle();
      });
    },
    progressall: function (e, data) {
      $('#progress').show();
    }
  }).prop('disabled', !$.support.fileInput)
  .parent().addClass($.support.fileInput ? undefined : 'disabled')
  .bind('fileuploadadd', function (e, data) { $('input:submit').attr('disabled', 'disabled').toggleClass('disabled') })
  .bind('fileuploaddone', function (e, data) { $('input:submit').attr('disabled', null).toggleClass('disabled') });

  $('.file').hover(function(e) {
    e.preventDefault();
    $(this).find('.delete-attachment').velocity("fadeIn", { duration: 250 });
  }, function(e) {
    $(this).find('.delete-attachment').velocity("fadeOut", { duration: 250 });
  });

  $('.year_nav').hover(function(e) {
    e.preventDefault();
    $(this).find('.past_years').velocity("fadeIn", { duration: 250 });
  }, function(e) {
    $(this).find('.past_years').velocity("fadeOut", { duration: 250 });
  });

});
