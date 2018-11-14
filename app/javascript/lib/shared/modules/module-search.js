$(document).on('turbolinks:load', function() {
  var $input = $('input#gobierto_search');
  var $resultsContainer = $('#search_results, #search_results:hidden');

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

  function itemType(d){
    if(d['class_name'] === undefined)
      return;

    switch(d['class_name']){
      case 'GobiertoPeople::Person':
        return I18n.t("layouts.search.person_item");
      case 'GobiertoPeople::PersonPost':
        return I18n.t("layouts.search.person_post_item");
      case 'GobiertoCalendars::Event':
        return I18n.t("layouts.search.event_item");
      case 'GobiertoParticipation::Contribution':
        return I18n.t("layouts.search.contribution_item");
      case 'GobiertoParticipation::Process':
        return I18n.t("layouts.search.process_item");
      case 'GobiertoPeople::PersonStatement':
        return I18n.t("layouts.search.person_statement_item");
      case 'GobiertoCms::Page':
        return I18n.t("layouts.search.page_item");
      case 'GobiertoBudgets::BudgetLine':
        if (d['kind'] === 'I') {
          return I18n.t("layouts.search.budget_line_item_income");
        } else {
          return I18n.t("layouts.search.budget_line_item_expense");
        }
      case 'GobiertoCitizensCharters::Charter':
        return I18n.t("layouts.search.charter");
      case 'GobiertoCitizensCharters::Commitment':
        return I18n.t("layouts.search.charter_commitment");
    }
  }

  function searchFrontCallback(err, content) {
    if (err) {
      console.error(err);
      return;
    }

    $resultsContainer.html('');
    var sum = 0;
    content.results.forEach(function(indexResults){
      sum += indexResults.nbHits;
    });

    if(sum > 0) {
      content.results.forEach(function(indexResults){
        indexResults.hits.forEach(function(d){

          var result = '<a class="result" <a href="' + d.resource_path + '">' +
            '<h2>' + (d['title'] || d['name'] || d['title_' + I18n.locale] || d['name_' + I18n.locale]) + '</h2>' +
            '<div class="description">' +
              '<div>' + itemDescription(d) + '</div>' +
              '<span class="soft item_type">' + itemType(d) + '</span>' +
              (itemUpdatedAt(d) ? ' · <span class="soft updated_at">' + itemUpdatedAt(d) + '</span>' : '') +
            '</div>' +
          '</a>';

          var div = $(result);
          div.appendTo($resultsContainer);
        });
      });
    } else {
      $('<div class="result"><p>'+I18n.t("layouts.search.no_results")+'</p></div>').appendTo($resultsContainer);
    }

    if(window.searchClient.indexes.length > 1) {
      $('<div class="result"><small>'+I18n.t("layouts.search.powered_by")+'</small></div>').appendTo($resultsContainer);
    }
  }

  $input.on('keyup', function(){
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

    if(q.length > 2){
      window.searchClient.client.search(queries, searchFrontCallback);
    } else {
      $resultsContainer.html('');
    }
  });

  $input.focusin(function() {
    $resultsContainer.show();
  });

  // Hide resultsContainer if clicked outside the search input and results
  $('body').click(function(e) {
    if ( !$(e.target).is('#search_results *') && !$(e.target).is('input#gobierto_search') ) {
      $resultsContainer.hide();
    }
  });
});
