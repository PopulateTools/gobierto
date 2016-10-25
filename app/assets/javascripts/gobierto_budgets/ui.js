'use strict';

function rebindAll() {
  $('.tipsit').tipsy({fade: true, gravity: 's', html: true});
  $('.tipsit-n').tipsy({fade: true, gravity: 'n', html: true});
  $('.tipsit-w').tipsy({fade: true, gravity: 'w', html: true});
  $('.tipsit-e').tipsy({fade: true, gravity: 'e', html: true});
  $('.tipsit-treemap').tipsy({fade: true, gravity: $.fn.tipsy.autoNS, html: true});
}

function responsive() {
  if($(window).width() > 740) {
    return true;
  }
}

$(function(){
  // Modals
  $('.open_modal').magnificPopup({
    type: 'inline',
    removalDelay: 300,
    mainClass: 'mfp-fade'
    // other options
  });

  $('body').on('click', '.popup', function(e){
    e.preventDefault();
    window.open($(this).attr("href"), "popupWindow", "width=600,height=600,scrollbars=yes");
    if($(this).data('rel') !== undefined){
      ga('send', 'event', 'Social Shares', 'Click', $(this).data('rel'), {nonInteraction: true});
      mixpanel.track('Social Shares', { 'Click': $(this).data('rel')});
    }
  });

  if($(window).width() > 740) {
    rebindAll();
  }

  var searchOptions = {
    serviceUrl: '/search',
    onSelect: function(suggestion) {
      if(suggestion.data.type == 'Place') {
        ga('send', 'event', 'Place Search', 'Click', 'Search', {nonInteraction: true});
        mixpanel.track('Place Search', { 'Place': suggestion.data.slug});
        window.location.href = '/places/' + suggestion.data.slug;
      }
    },
    groupBy: 'category'
  };

  $('.search_auto').autocomplete($.extend({}, AUTOCOMPLETE_DEFAULTS, searchOptions));
  $('.global .ham .fa-bars').click(function(e){
    e.preventDefault();
    $('.global .desktop').toggle();
  });

  var $searchBudget = $('.search_categories_budget-expense');
  var searchCategoriesOptions = {
    serviceUrl: $searchBudget.data('search-url'),
    onSelect: function(suggestion) {
      window.location.href = suggestion.data.url;
    }
  };
  $searchBudget.autocomplete($.extend({}, AUTOCOMPLETE_DEFAULTS, searchCategoriesOptions));

  $searchBudget = $('.search_categories_budget-income');
  searchCategoriesOptions = {
    serviceUrl: $searchBudget.data('search-url'),
    onSelect: function(suggestion) {
      window.location.href = suggestion.data.url;
    }
  };
  $searchBudget.autocomplete($.extend({}, AUTOCOMPLETE_DEFAULTS, searchCategoriesOptions));

  $('.sticky').sticky({topSpacing:0});

  $('#kind').on('change', function(e){
    $.ajax('/categories/economic/' + $(this).val());
  });

  $('#year,#population').on('change', function(e){
    submitForm();
  });

  $(".places_menu ul li").hover(function(e){
    // e.preventDefault();
    $(this).find('ul').toggle();
  });

  $('.metric').on('click','.ranking_link', function(e){
    e.stopImmediatePropagation();
  })

  function render_comp_table(what) {
    what = what.replace('_','-');
    var other = (what == 'per-person') ? 'total-budget' : 'per-person';
    $('.variable_values').each(function() {
      $(this).find('.selected_indicator').text($(this).data(what));
    });
    $('li.' + what).show();
    $('li.' + other).hide();
  }

  if($('.comparison_table').length > 0) {
    var $widget = $('[data-line-widget-url].selected');
    render_comp_table($widget.data('line-widget-type'));
  }

  $(document).on('click', '[data-feedback]', function(e){
    e.preventDefault();
    $('.metric_graphs').hide();
    $('.budget_line_feedback.hidden').removeClass('hidden');
  });

  // adjust height of sidebar
  // if($(window).width() > 740) {
  if(responsive()) {
    $('header.global').css('height', $(document).height());
  };

  $('.switcher').hover(function(e) {
    e.preventDefault();
    $(this).find('ul').show();
  }, function(e) {
    $(this).find('ul').hide();
  });

  $('.year_switcher').click(function(e){
    ga('send', 'event', 'Year Selection', 'Click', 'ChangeYear', {nonInteraction: true});
    mixpanel.track('Year Selection', { 'Year Selected': e.target.innerHTML});
  });

  $('.home_section .switcher').click(function(e){
    e.preventDefault();
    var tgt = $(e.target);
    var value = tgt.data('value');
    var switcher = tgt.parents('.switcher');
    var selected = switcher.find('a.selected');
    selected.data('value', value);
    selected.html(tgt.text() + " <i class='fa fa-angle-down'></i>");
    switcher.find('ul').hide();

    var form = tgt.parents('form');
    var action = form.attr('action');
    console.log(value);
    var kind_re = /[GI]\/.*\//;

    if (value == 'I') {
      action = action.replace(kind_re, 'I/economic/');
    }
    else if (value == 'G') {
      action = action.replace(kind_re, 'G/functional/');
    }
    else {
      $('input#f_aarr[type=hidden]').val(value);
    }

    form.attr('action',action);

  });

  $('.modal_widget').hover(function(e) {
    // e.preventDefault();
    $(this).find('.inner').velocity("fadeIn", { duration: 50 });
    var eventLabel = $(this).attr('id');
    ga('send', 'event', 'Header Tools', 'Hover', eventLabel, {nonInteraction: true});
    mixpanel.track('Header Tools', { 'Modal': eventLabel, 'Action': 'Hover'});
  }, function(e) {
    $(this).find('.inner').velocity("fadeOut", { duration: 50 });
  });

  $('.modal_widget').click(function(e) {
    var eventLabel = $(this).attr('id');
    ga('send', 'event', 'Header Tools', 'Click', eventLabel, {nonInteraction: true});
    mixpanel.track('Header Tools', { 'Modal': eventLabel, 'Action': 'Click'});
    if($('.modal_widget .inner').css('display') == 'none') {
      // e.preventDefault();
      $(this).find('.inner').velocity("fadeIn", { duration: 50 });
    }
  });

  $('#follow_link').click(function(e) {
    e.preventDefault();
    $('#user_email').focus();
  });

  $('.modal_widget li').hover(function(e) {
    e.preventDefault();
    $(this).find('.del_item').velocity("fadeIn", { duration: 0 });
  }, function(e) {
    $(this).find('.del_item').velocity("fadeOut", { duration: 0 });
  });

  $('th.location').hover(function(e) {
    e.preventDefault();
    $(this).find('.remove').velocity("fadeIn", { duration: 100 });
  }, function(e) {
    $(this).find('.remove').velocity("fadeOut", { duration: 100 });
  });

  $('th.add_location_cont').click(function(e) {
    e.preventDefault();
    $('.add_location input').focus();
  });

  $('th.add_location_cont').hover(function(e) {
    $('.add_location input').focus();
    $(this).find('.add_location').velocity("fadeIn", { duration: 100 });
  }, function(e) {
    $(this).find('.add_location ').velocity("fadeOut", { duration: 100 });
  });

  function parent_treemap_url(parent_url) {
    var pattern = /parent_code=\d+/;
    parent_url = parent_url.replace(pattern, function(match) {
      return match.substring(0,match.length - 1)
    });
    return parent_url + '&amp;format=json';
  }

  /* Tree navigation */
  $('.items').on('ajax:success', 'a[data-remote=true]', function(event, data, status, xhr) {
    $(this).addClass('extended');
    $(this).find('.fa').toggleClass('fa-plus-square-o fa-minus-square-o');
    ga('send', 'event', 'Tree Navigation', 'Open', $(this).attr('href'), {nonInteraction: true});
    mixpanel.track("Tree Navigation", {"Open": $(this).attr('href')});
  });

  /* Collapses branch - Prevents resending the form when extended */
  $('.items').on('ajax:beforeSend', 'a.extended', function(event, xhr, settings) {
    xhr.abort();
    $(this).removeClass('extended');
    $(this).find('.fa').toggleClass('fa-plus-square-o fa-minus-square-o');
    $(this).parents('tr').next('.child_group').remove();

    var url = parent_treemap_url($(this).attr('href'));
    if ($('#income-treemap').is(':visible'))
      window.incomeTreemap.render(url);
    if ($('#expense-treemap').is(':visible'))
      window.expenseTreemap.render(url);
    ga('send', 'event', 'Tree Navigation', 'Close', '', {nonInteraction: true});
    mixpanel.track("Tree Navigation", {"Close": $(this).attr('href')});
  });

  $('.items').on('ajax:beforeSend', 'a:not(.extended)', function(event, xhr, settings) {
    var sibs = $(this).parents('tr:not(.child_group)').siblings();
    sibs.find('a.extended').removeClass('extended').find('.fa').toggleClass('fa-plus-square-o fa-minus-square-o');
    sibs.siblings('.child_group').remove();
  });

  if($('#income-treemap').length > 0){
    window.incomeTreemap = new TreemapVis('#income-treemap', 'big', true);
    window.incomeTreemap.render($('#income-treemap').data('economic-url'));
  }

  if($('#expense-treemap').length > 0){
    window.expenseTreemap = new TreemapVis('#expense-treemap', 'big', true);
    window.expenseTreemap.render($('#expense-treemap').data('functional-url'));
  }

  var hash = window.location.hash.slice(1);
  var action = $('body').data('action');
  if($('[data-widget-type]').length > 0 && hash !== "")
    $("[data-widget-type='" + hash + "']").addClass('selected');
  else if (hash === '' && action === 'execution')
    $("[data-widget-type='total_budget_execution']").addClass('selected');
  else
    $('[data-widget-type]:first').addClass('selected');

  var visLineasJ;
  var widgetClicked = function(e){
    e.preventDefault();
    var $widget = $(this);

    $('.selected').removeClass('selected');
    $widget.addClass('selected');

    if($('.comparison_table').length > 0) {
      $widget.addClass('selected');
      render_comp_table($widget.data('line-widget-type'));
    }

    if ($('#lines_chart').length && $(this).data('line-widget-url') !== undefined) {
      $widget.addClass('selected');
      visLineasJ.measure = $widget.data('line-widget-type');
      visLineasJ.render($(this).data('line-widget-url'));
    } else if($(this).data('page-href') !== undefined) {
      Turbolinks.visit($(this).data('page-href'));
    } else {
      return false;
    }
  }

  // There's an equivalent code in components/vis_line but it uses the class
  // active instead of selected. Using the class active should allow us to remove
  // this code
  if($('#lines_chart').length > 0){
    var $widget = $('[data-line-widget-url].selected');
    visLineasJ = new VisLineasJ('#lines_chart', '#lines_tooltip', $widget.data('line-widget-type'), $widget.data('line-widget-series'));
    visLineasJ.render($widget.data('line-widget-url'));
  }

  $('[data-line-widget-url],[data-page-href]').on('click',widgetClicked);

  // When the treemap is clicked, we extract the URL of the node
  // and detect which is the link that expands the tree nodes with the
  // children. That node is clicked, and it triggers the treemap re-rendering
  $('body').on('click', '.treemap_node', function(e){
    e.preventDefault();
    // Remove all open tipsy
    $('.tipsit-treemap').each(function(){
      $(this).data('tipsy').hide();
    });
    var url = $(this).data('url');
    var parser = document.createElement('a');
    parser.href = url;
    url = parser.pathname + parser.search;
    var parts = url.split('?');
    url = parts[0].split('.')[0] + '?' + parts[1];
    $('a[href="'+ url + '"]').click();
  });

  $('header.place').bind('inview', function(event, isInView) {
    if (isInView) {
      $('.tools').css('z-index', 10);
      $('header.sticky_top').velocity("fadeOut", { duration: 50 });
    } else {
      $('.tools').css('z-index', 200);
      $('header.sticky_top').velocity("fadeIn", { duration: 50 });
    }
  });

  $('.tabs li a').click(function(e) {
    e.preventDefault();
    $(this).parent().parent().find('li a').removeClass('active');
    $(this).addClass('active');
    var tab = $(this).data("tab-target");
    $('.tab_content').hide();
    $('.tab_content[data-tab="'+tab+'"]').show();
  });

  // Tabs navigation
  $('[data-tab-target]').on('click', function(e){
    e.preventDefault();
    var target = $(this).data('tab-target');
    $('[data-tab-target]').removeClass('active');
    $('[data-tab-target="' + target + '"]').addClass('active');

    $('[data-tab]').hide();
    $('[data-tab="' + target + '"]').show();
  });

  $('[data-link]').click(function(e){
    e.preventDefault();
    window.location.href = $(this).data('link');
  });

  var ie_intro_height = $('.ie_intro').height();
  $('[data-rel="cont-switch"]').click(function(e){
    e.preventDefault();
    var target = $(this).data('target');
    $('.ie_intro').css('min-height', ie_intro_height);
    $(this).parents('div:eq(0)').velocity('fadeOut',
      {
        duration: 100,
        complete: function(e) {
          $('.' + target).velocity('fadeIn', {
            duration: 100,
            complete: function(e) {
              $(this).removeClass('hidden');
              if (target.indexOf('income') > 1) {
                window.incomeTreemap.render($('#income-treemap').data('economic-url'));
              }
              else {
                window.expenseTreemap.render($('#expense-treemap').data('functional-url'));
              }
            }});
        }
      }
    );

  });


  /*
   * Google Analytics Events
   *
  */
  $('.form_filters a').click(function(e) {
    var eventLabel = $(this).attr('id');
    ga('send', 'event', 'Expense Type Selector', 'Click', eventLabel, {nonInteraction: true});
    mixpanel.track("Expense Type Selector", {"Type": eventLabel});
  });

  $('.ranking_card').click(function(e) {
    Turbolinks.visit($(this).find('h2 a').attr('href'));
  });


  $('.toggle_div').on('click', function(e){
    e.preventDefault();
    $('.'+$(this).data('target')).toggle();
  });

});
