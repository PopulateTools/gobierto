$(function () {
  'use strict';

  Cookies.json = true;
  Cookies.defaults.path = '/';

  function storePlaceVisit(){
    var $trackUrl = $('[data-track-url]');
    if($trackUrl.length == 0) { return; }

    var places = Cookies.get('places');
    if(places === undefined) { places = []; }

    var placeInformation = $trackUrl.data('place-name') + '|' + $trackUrl.data('track-url') + '|' + $trackUrl.data('place-slug');

    if (places.indexOf(placeInformation) == -1){
      places.unshift(placeInformation);
    }
    else {
      // we put it at the front
      var repeat = places.splice(places.indexOf(placeInformation),1)[0];
      places.unshift(repeat);
    }

    if(places.length > 10) { places.pop(); }

    Cookies.set('places', places);
  }

  function storeComparisonVisit(){
    var $trackUrl = $('[data-comparison-track-url]');
    if($trackUrl.length == 0) { return; }

    var comparisons = Cookies.get('comparisons');
    if(comparisons === undefined) { comparisons = []; }

    var comparisonInformation = $trackUrl.data('comparison-name') + '|' + $trackUrl.data('comparison-track-url') + '|' + $trackUrl.data('comparison-slug');

    if (comparisons.indexOf(comparisonInformation) == -1){
      comparisons.unshift(comparisonInformation);
    }
    else {
      // we put it at the front
      var repeat = comparisons.splice(comparisons.indexOf(comparisonInformation),1)[0];
      comparisons.unshift(repeat);
    }

    if(comparisons.length > 10) { comparisons.pop(); }

    Cookies.set('comparisons', comparisons);
  }

  function renderCookiesHistory(container, cookieName){
    var $history = $(container);
    var elements = Cookies.get(cookieName);

    if(elements === undefined) {
      elements = [];
    }

    if($history !== undefined){

      var $listElements = [];
      for(var i = 0; i < elements.length; i++){
        var placeInformation = elements[i].split('|');
        var placeName = placeInformation[0];
        var placeURL = placeInformation[1];
        var placeYear = /(\d+)/.exec(placeURL)[0];
        placeName += ' (' + placeYear +')';
        $listElements.push('<li><a href=' + placeURL + '>' + placeName + '</a></li>');
      }

      $history.html($listElements.join("\n"));
    }
  }

  storePlaceVisit();
  storeComparisonVisit();
  renderCookiesHistory('#history','places');
  renderCookiesHistory('#comparisons-history','comparisons');
});
