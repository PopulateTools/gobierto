import 'devbridge-autocomplete';
import '../../../assets/stylesheets/modules/jquery-ui.css';
import '../../lib/commons/modules/jquery-ui';
import { AUTOCOMPLETE_DEFAULTS } from '../../lib/shared';

$(document).on('turbolinks:load', function() {
  var $input_admin = $('input#pages_search')
  var $resultsContainerAdmin = $('#search_pages')
  var initial_search_html = $resultsContainerAdmin.html()

  function truncateOnWord(str, limit) {
    var trimmable = '\u0009\u000A\u000B\u000C\u000D\u0020\u00A0\u1680\u180E\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u2028\u2029\u3000\uFEFF'
    var reg = new RegExp('(?=[' + trimmable + '])')
    var words = str.split(reg)
    var count = 0
    return words.filter(function(word) {
      count += word.length
      return count <= limit
    }).join('')
  }

  function itemUpdatedAt(d){
    if (d['searchable_updated_at'] == null)
      return

    return `${I18n.t("layouts.search.updated")}: ${I18n.l("date.formats.short", d['searchable_updated_at'])}`
  }

  function itemDescription(d){
    if (d["meta"] == null)
      return ''

    let maxLength = 200
    let description_translations = (d['meta']['collection_title_translations'] || {})
    let description = (description_translations[I18n.locale] || '')
    if (description === '' || description.length < maxLength)
      return description
    return truncateOnWord(description, maxLength) + '...'
  }

  function itemCollectionId(d){
    if (d["meta"] == null)
      return

    return d["meta"]["collection_id"]
  }

  function formattedResult(d){
    return '<div class="activity_item">' +
             `<h2><a class="tipsit" href="${["/admin/cms/pages/", d['searchable_id'], "/edit?collection_id=", itemCollectionId(d)].join('')}"` +
             ` original-title="${I18n.t("layouts.search.drag_drop_instructions")}"` +
             ` data-title="${d['title']}"` +
             ` data-id=${d['searchable_id']}>` +
             d['title'] +
             `<span class="secondary">${itemDescription(d)}</span>` +
             '</a></h2>' +
             `<div class="date">${itemUpdatedAt(d)}</div>` +
           '</div>'
  }

  var searchOptions = {
    serviceUrl: '/api/v1/search',
    minChars: 1,
    dataType: 'json',
    params: window.searchClient === undefined ?
      {} :
      {
      filters:
        {
        searchable_type: window.searchClient.searchable_types
      }
    },
    beforeRender(container) {
      container.css({ width: '100%' })
    },
    triggerSelectOnValidInput: false,
    transformResult: function(response) {
      return {
        suggestions: response.data.map(item => ({
          value: item.attributes.title,
          data: item.attributes
        }))
      }
    },
    formatResult: function(){
      return ''
    },
    onSearchComplete: function(query, suggestions){
      $("div.autocomplete-suggestions").hide()
      $resultsContainerAdmin.html('')
      if (suggestions.length > 0 ) {

        suggestions.forEach(function(suggestion){
          let result = formattedResult(suggestion.data)

          let div = $(result)
          div.appendTo($resultsContainerAdmin)
        })

      // After reload partial with pages we have to do pages like draggable
      $(".tipsit").draggable({ revert: true })
    } else {
      $('<div class="result"><p>'+I18n.t("layouts.search.no_results")+'</p></div>').appendTo($resultsContainerAdmin)
    }
    },
    showNoSuggestionNotice: false
  }

  $input_admin.devbridgeAutocomplete($.extend({}, AUTOCOMPLETE_DEFAULTS, searchOptions))

  $input_admin.on('keyup', function(){
    var q = $(this).val()
    if (q.length == 0)
      $resultsContainerAdmin.html(initial_search_html)
  })

  $input_admin.focusin(function() {
    $resultsContainerAdmin.show()
  })
})
