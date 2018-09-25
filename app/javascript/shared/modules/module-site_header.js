import 'velocity-animate'

$(document).on('turbolinks:load', function() {

  $('.nav_control, .close').click(function(e) {
    e.preventDefault();

    $('body').velocity('scroll', {
      duration: 500,
      offset: -40,
      easing: 'ease-in-out'
    });

    // Style itself
    var $selector;
    if($(this).hasClass('nav_control'))
      $selector = $('.nav_control');
    else
      $selector = $('.close');

    $selector.find('i').toggleClass('fa-bars fa-close');
    $selector.parent().toggleClass('hamburger_container--transparent');

    $('.js-mobile-header').toggle();
    $('.js-mobile-nav').toggle();
    $('.js-mobile-buttons').toggle();
  });

  $('.site_header_logo .search_icon').click(function(e) {
    e.preventDefault();
    $('.search_control').velocity("fadeIn", {
      complete: function (element) {
        $(element[0]).find('input').removeClass('hidden').focus();
      }
    });
  });

  $('.site_header_logo .search_control input').on('focusout', function() {
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

  $('.scroll-up').on('click', function() {
    $('body').velocity('scroll', {
      duration: 500,
      offset: -40,
      easing: 'ease-in-out'
    });
  });

  $('.js-submenu-toggle').on('click', function() {
    $('.js-slider:visible').toggleClass('is-open');
  });

  $('.js-item-toggle').on('click', function() {
    var parent = $(this).parent();

    // If open same menu-item, just close it.
    if (parent.next().find('.js-slider').hasClass('is-open')) {
      parent.next().find('.js-slider').removeClass('is-open');
      return;
    }

    // Closes all menus
    parent.closest('.js-mobile-nav').find('.is-open').removeClass('is-open');

    // Delayed to get accordion effect
    setTimeout(function () {
      // Open sibling menu
      parent.next().find('.js-slider').toggleClass('is-open');
    }, 200);

    // REVIEW:
    // if ($(this).prev().find('a').attr('href') === "/participacion") {
    //   $('.js-secondary_nav').addClass('is-open');
    // } else {
    //   $('.js-secondary_nav').removeClass('is-open');
    // }
  });

});
