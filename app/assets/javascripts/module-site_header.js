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

  $('.nav .search_box input').focus(function(e) {
    $(this).velocity({width: '250px'});
  });
  $('.nav .search_box input').blur(function(e) {
    $(this).velocity({width: '150px'});
  });

});
