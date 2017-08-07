
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

  $('.site_header_logo .search_icon').click(function(e) {
    e.preventDefault();
    $('.search_control').velocity("fadeIn", {
      complete: function (element) {
        $(element[0]).find('input').removeClass('hidden').focus();
      }
    });
  });

  $('.site_header_logo .search_control input').on('focusout', function(e) {
    $('.search_control').velocity("fadeOut");
  });

  $('.follow_process').on('click', function() {
    $(this)
      .toggleClass('checked')
      .find('.fa')
      .toggleClass('fa-rss fa-star')
      .velocity({ translateY: -5 }, { duration: 100, loop: 2 })
      .next('span')
      .toggleText('Sigue este proceso', '¡Proceso seguido!');
  });

});
