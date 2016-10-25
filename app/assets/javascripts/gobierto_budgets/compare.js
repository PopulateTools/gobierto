$(function () {
  'use strict';

  Cookies.json = true;
  Cookies.defaults.path = '/';

  var addPlaceOptions = {
    serviceUrl: '/search',
    onSelect: function (suggestion) {
      if(suggestion.data.type == 'Place') {
        var places_list = Cookies.get('comparison');
        var new_place = suggestion.data.slug + '|' + suggestion.data.id + '|' + suggestion.data.slug
        places_list.push(new_place);
        window.location.href = compareUrl(places_list);
      }
    },
    groupBy: 'category'
  }

  $('#add_place').autocomplete($.extend({}, AUTOCOMPLETE_DEFAULTS, addPlaceOptions));

  function compareUrl(list) {
    var slugs = $.map(list, function(place, i) {
      return place.split('|')[2];
    });
    var year = $('body').data('year');
    var area = $('body').data('area');
    var kind = $('body').data('kind');

    var url = window.location.protocol + "//" + window.location.hostname + ":" + window.location.port + "/compare/";
    url += slugs.join(':');
    url += "/" + year + "/" + kind + "/" + area;
    return url;
  }

  //assumes the places cookie is set
  function updateListAndCompare(place, parentCode){
    var comparison = Cookies.get('comparison');
    if (comparison === undefined)
      comparison = [];

    if (comparison.indexOf(place) === -1)
      comparison.unshift(place);

    Cookies.set('comparison', comparison);

    compare(parentCode);
  }

  function removeFromList(place_name) {
    var comparison = Cookies.get('comparison');

    var i = comparison.findIndex(function(el) {
      return el.indexOf(place_name) == 0
    })

    if (i > -1) {
      comparison.splice(i,1);
      Cookies.set('comparison',comparison);
    }
  }

  function compare(parentCode) {
    var comparison = Cookies.get('comparison');
    var compare_url = compareUrl(comparison);

    if (parentCode !== null && parentCode !== undefined) {
      compare_url += "?parent_code=" + parentCode;
    }
    window.location.href = compare_url;
  }

  function currentPlaceIsOnList(place) {
    var comparison = Cookies.get('comparison');

    return comparison.indexOf(place) > -1;
  }

  function renderCompareList(list) {
    var $compare_list = $('#compare_list');
    var $list_elements = [];

    if (list.length > 0) {
      for(var i = 0; i < list.length; i++){
        var placeInformation = list[i].split('|');
        var placeName = placeInformation[0];
        var placeURL = placeInformation[1];
        $list_elements.push('<li><a href="' + placeURL + '">' + placeName + '</a> <span class="del_item"><a href="#" class="del_link">X</a></span></li>');
      }

      $compare_list.html($list_elements.join("\n"));

      $('.js-add_compare').each(function(){
        var place = $(this).data('place');
        if (currentPlaceIsOnList(place)) {
          $(this).hide();
          $('#without_current_note').hide();
          $('.widget_compare .sep').hide();
        }
      });
    } else {
      $('#view_comp_container').hide();
    }

  }

  function gatherCompareList() {
    var comparison = Cookies.get('comparison');

    if (comparison === undefined || comparison.length == 0) {
      comparison = [];

      var recent_places = Cookies.get('places');

      if (recent_places == 'undefined') {
        // if the compare list is empty, we take the site that was previously visited so that he can compare
        // the current one and the previous one
        renderCompareList([recent_places[1]]);
      }
      else {
        renderCompareList([]);
      }
    }
    else {
      renderCompareList(comparison);
    }

    Cookies.set('comparison', comparison);
  }

  function overwriteComparisonListWithComparedPlaces() {
    var comparison = $('.compared_place').map(function(i,place) {
      return $(place).text().trim() + "|" + $(place).attr('href') + "|" + $(place).data('slug');
    }).get();

    if (comparison.length > 0)
      Cookies.set('comparison',comparison);
  }

  $('.js-add_compare, .js-add_compare_no_hide').on('click', function(e) {
    e.preventDefault();
    updateListAndCompare($(this).data('place'), $(this).data('parent-code'));
  });

  $('#view_compare').on('click', function(e) {
    e.preventDefault();
    compare($(this).data('parent-code'));
  });

  $('#compare_list').on('click', 'a.del_link', function(e) {
    e.preventDefault();
    var $list_item = $(this).parents('li');
    var place = $list_item.children('a').text().trim();
    removeFromList(place);
    $list_item.remove();
  });

  $('.comparison_table').on('click','a.remove', function(e) {
    e.preventDefault();
    var $th = $(this).parents('th');
    var place = $th.children('a:not(.remove)').text().trim();

    removeFromList(place);
    compare();
  });

  gatherCompareList();

  if (window.location.pathname.indexOf('compare') > -1)
    overwriteComparisonListWithComparedPlaces();

});
