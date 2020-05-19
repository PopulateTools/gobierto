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

export function uuid() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = Math.random() * 16 | 0,
          val = c == 'x' ? r : (r & 0x3 | 0x8);

    return val.toString(16);
  });
}
