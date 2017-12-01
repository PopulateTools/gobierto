
$(document).on('turbolinks:load', function() {
  $('.nav_control, .close').click(function(e) {
    e.preventDefault();

    var nav = $('.main-nav');
    var subnav = $('.sub-nav');

    if( nav.css('display') == 'none' ) {
      nav.velocity("transition.slideDownIn");
      subnav.velocity("transition.slideDownIn", { delay: 150 });
    } else {
      nav.velocity("transition.slideUpOut");
      subnav.velocity("transition.slideUpOut");
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
