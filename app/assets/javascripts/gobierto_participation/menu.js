'use strict';

window.rebindAll = function(){
  // $('.tipsit').tipsy({fade: true, gravity: 's'});
  // $('.tipsit-n').tipsy({fade: true, gravity: 'n'});
}

$(function(){

  function global_menu(menu) {

    if($('menu.global .content').position().left == '50') {

      // pending: close when clicking outside of container

      // close when ESC key pressed
      $(document).on('keydown', function(e) {
        if (e.keyCode === 27)  {
          global_menu_close();
        }
      });

      var opened_menu = $('.content .cont').filter(":visible").attr('data-menu-section');
      if(menu != opened_menu) {
        global_menu_open(menu);
      } else {
        global_menu_close();  
      }
    }
    else {
      global_menu_open(menu);
    }
  }

  function global_menu_close() {
    
    if($(window).width() < 740) {
      $('menu.global .content').velocity({ 
        translateX: "-740",
        opacity: 1
      }, 250);
      $('menu.global').velocity({opacity: 0}, {
        complete: function() { $('menu.global').removeClass('global_open'); }
      }, 250);
      // $('menu.global').delay(1000).removeClass('global_open'); 
    } else {
      $('menu.global .content').velocity({ 
        translateX: -950,
        opacity: 0
      }, 350);  
    }
    $('.desktop-c').show();
  }

  function global_menu_open(menu) {
    $('.content .cont').hide();
    $('.desktop-c').hide();
    $('.'+menu).show();
    
    if($(window).width() < 740) {
      $('menu.global').velocity("fadeIn", { duration: 250 });
      $('menu.global').addClass('global_open'); 
      $('menu.global .content').velocity({ 
        translateX: 740,
        opacity: 1
      }, 250);
    } else {
      $('menu.global .content').velocity({ 
        translateX: 950,
        opacity: 1
      }, 250);
    } 
    
  }

  $('[data-menu]').click(function(e) {
    e.preventDefault();
    var menu = $(this).attr("data-menu");
    if(menu == 'close') {
      global_menu_close();
    } else {
      global_menu(menu);  
    }
  });

  if(window.location.hash == '#menu-account'){
    global_menu('account');
  }

});
