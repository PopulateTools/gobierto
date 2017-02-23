$(document).on('turbolinks:load', function() {
  var $input = $('input#gobierto_search');

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
    var description = (d['bio'] || d['description'] || d['body'] || '');
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
      case 'GobiertoPeople::PersonEvent':
        return I18n.t("layouts.search.person_event_item");
      case 'GobiertoPeople::PersonStatement':
        return I18n.t("layouts.search.person_statement_item");
      case 'GobiertoCms::Page':
        return I18n.t("layouts.search.page_item");
    }
  }

  function searchCallback(err, content) {
    if (err) {
      console.error(err);
      return;
    }

    var $resultsContainer = $('#search_results');
    $resultsContainer.html('');
    content.results.forEach(function(indexResults){
      indexResults.hits.forEach(function(d){
        var result = '<div class="result">' +
					'<h2><a href="'+d.resource_path+'">' + (d['title'] || d['name']) + '</a></h2>' +
					'<div class="description">' +
            '<div>' + itemDescription(d) + '</div>' +
						'<span class="soft item_type">' + itemType(d) + '</span> · ' +
						'<span class="soft updated_at">' + itemUpdatedAt(d) + '</span>' +
					'</div>' +
				'</div>';

        var div = $(result);
        div.appendTo($resultsContainer);
      });
    });
  }

  $input.on('keyup', function(e){
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
      window.searchClient.client.search(queries, searchCallback);
    }
  });
});
