import * as d3 from 'd3'

export function getRemoteData(endpoint) {
  return new Promise((resolve) => {
    d3.csv(endpoint)
      .mimeType("text/csv")
      .get(function(error, csv) {
        if (error) throw error;

        resolve(csv);
      });
  })
}

export function sortByField(dateField) {
  return function(a, b){
    const aDate = a[dateField],
          bDate = b[dateField];

    if (aDate == '') {
      return 1;
    }

    if (bDate == '') {
      return -1;
    }

    if ( aDate < bDate ){
      return 1;
    } else if ( aDate > bDate ){
      return -1;
    } else {
      return 0;
    }
  }
}
