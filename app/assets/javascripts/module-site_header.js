
$(document).on('turbolinks:load', function() {
  $('.nav_control, .close').click(function(e) {
    e.preventDefault();
    if( $('.menu.complete').css('display') == 'none' ) {
      $('.nav').attr('aria-hidden', 'true');
      $('.menu.complete').attr({
        'aria-hidden': 'false',
        'aria-expanded': 'true'
      });
      $('.menu.complete').velocity("transition.slideDownIn");
      if(($(window).width() < 740)) {
        $('.menu.complete').velocity("scroll", { offset: -30});
      }
      $('.menu.complete .close').velocity({
        display: 'block',
        top: '-2em'

      }, {
        delay: 150
      });
    }
    else {
      $('.nav').attr('aria-hidden', 'false');
      $('.menu.complete').attr({
        'aria-hidden': 'true',
        'aria-expanded': 'false'
      });
      $('.menu.complete .close').velocity({
        top: '2em'
      });
      $('.menu.complete').velocity("transition.slideUpOut", { delay: 150 });
    }
  });

  $('.site_header_logo .search_icon').focus(function(e) {
    $(this).velocity({ width: isMobile() ? '100px' : '170px' }, { complete: function (element) { $(element[0]).find('input').removeClass('hidden').focus(); }})
  });

  $('.site_header_logo .search_icon input').on('focusout', function(e) {
    $(this).parent('.search_icon').velocity({ width: '24px '}, { begin: function(element) { $(element[0]).find('input').addClass('hidden'); }});
  })
});
