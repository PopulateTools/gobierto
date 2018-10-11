// Fallback IE
const updateQueryStringParam = (key, value, url) => {
  let urlQueryString = url || ""
  // let urlQueryString = document.location.search
  let newParam = key + '=' + value
  let params = newParam

  // If the "search" string exists, then build params from it
  if (urlQueryString) {
    var updateRegex = new RegExp('([?&])' + key + '[^&]*');
    var removeRegex = new RegExp('([?&])' + key + '=[^&;]+[&;]?');

    if (typeof value == 'undefined' || value == null || value == '') { // Remove param if value is empty
      params = urlQueryString.replace(removeRegex, "$1");
      params = params.replace(/[&;]$/, "");

    } else if (urlQueryString.match(updateRegex) !== null) { // If param exists already, update it
      params = urlQueryString.replace(updateRegex, "$1" + newParam);

    } else { // Otherwise, add it to end of query string
      params = urlQueryString + '&' + newParam;
    }
  }

  return params
};

export const URLParams = function(args) {

  let params = ""

  // Break if no endpoint
  if (!args.endpoint) throw "No endpoint provided"

  // Force param object to be present
  if (!args.hasOwnProperty("params")) {
    args.params = {}
  }

  if (URLSearchParams) {
    params = new URLSearchParams()

    for (var param in args.params) {
      if (args.params.hasOwnProperty(param)) {
        params.set(param, args.params[param])
      }
    }
  } else {
    params = ""
    // IE 10+
    for (var ieParam in args.params) {
      if (args.params.hasOwnProperty(ieParam)) {
        params = updateQueryStringParam(ieParam, args.params[ieParam], params)
      }
    }
  }

  return `${args.endpoint}?${params.toString()}`
}
