$(document).on('turbolinks:load', function() {
  var $input_admin = $('input#pages_search');
  var $resultsContainerAdmin = $('#search_pages');

  function truncateOnWord(str, limit) {
    var trimmable = '\u0009\u000A\u000B\u000C\u000D\u0020\u00A0\u1680\u180E\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u2028\u2029\u3000\uFEFF';
    var reg = new RegExp('(?=[' + trimmable + '])');
    var words = str.split(reg);
    var count = 0;
    return words.filter(function(word) {
      count += word.length;
      return count <= limit;
    }).join('');
  }

  function itemUpdatedAt(d){
    if(d['updated_at'] === undefined)
      return;

    return I18n.t("layouts.search.updated") + ": " + I18n.l("date.formats.short", d['updated_at']);
  }

  function itemDescription(d){
    var maxLenght = 200;
    var description = (d['bio'] || d['description'] || d['body'] || d['bio_' + I18n.locale] || d['description_' + I18n.locale] || d['body_' + I18n.locale] || '');
    if(description === '' || description.length < maxLenght)
      return description;
    return truncateOnWord(description, maxLenght) + '...';
  }

  function searchBackCallback(err, content) {
    if (err) {
      console.error(err);
      return;
    }

    $resultsContainerAdmin.html('');
    var sum = 0;
    content.results.forEach(function(indexResults){
      sum += indexResults.nbHits;
    });
    if(sum > 0) {
      content.results.forEach(function(indexResults){
        indexResults.hits.forEach(function(d){


          var result = '<div class="activity_item">' +
            '<h2>' + '<a class="tipsit" href=' + ["/admin/cms/pages/", d['objectID'], "/edit?collection_id=", d['collection_id']].join('') +
            ' original-title="' + I18n.t("layouts.search.drag_drop_instructions") + '"' +
            'data-title="' + (d['title'] || d['name'] || d['title_' + I18n.locale] || d['name_' + I18n.locale]) + '"' +
            'data-id=' + d['objectID'] + '>' +
            (d['title'] || d['name'] || d['title_' + I18n.locale] || d['name_' + I18n.locale]) +
            '<span class="secondary">' + itemDescription(d) + '</span>'  +
            '</a>' + '</h2>' +
            '<div class="date">' + itemUpdatedAt(d) + '</div>' +
          '</div>';

          var div = $(result);
          div.appendTo($resultsContainerAdmin);
        });
      });

      // After reload partial with pages we have to do pages like draggable
      $(".tipsit").draggable({ revert: true });
    } else {
      $('<div class="result"><p>'+I18n.t("layouts.search.no_results")+'</p></div>').appendTo($resultsContainerAdmin);
    }
  }

  $input_admin.on('keyup', function(){
    var q = $(this).val();
    var queries = [];
    window.searchClient.indexes.forEach(function(index){
      queries.push({
        indexName: index,
        query: q,
        params: {
          hitsPerPage: 10,
          filters: window.searchClient.filters
        }
      });
    });

    window.searchClient.client.search(queries, searchBackCallback);
  });

  $input_admin.focusin(function() {
    $resultsContainerAdmin.show();
  });
});
