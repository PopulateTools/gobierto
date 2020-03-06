"use strict";

// From https://www.abeautifulsite.net/parsing-urls-in-javascript
function parseURL(url) {
  var parser = document.createElement('a'),
      searchObject = {},
      queries, split, i;
  // Let the browser do the work
  parser.href = url;
  // Convert query string to object
  queries = parser.search.replace(/^\?/, '').split('&');
  for (i = 0; i < queries.length; i++) {
    split = queries[i].split('=');
    searchObject[split[0]] = split[1];
  }
  return {
    protocol: parser.protocol,
    host: parser.host,
    hostname: parser.hostname,
    port: parser.port,
    pathname: parser.pathname,
    search: parser.search,
    searchObject: searchObject,
    hash: parser.hash
  }
}

function iFrame() {
  let node = document.getElementById("gobierto-embed");
  if (node === null) { throw "Iframe gobierto-embed not found!"; }
  return node;
}

function removeSubstring(original, substr) {
  let originalPathName = parseURL(original).pathname;
  let pathName = parseURL(substr).pathname;
  let newPath = originalPathName.replace(pathName, "");
  return (newPath === "" ? "/" : newPath);
}

function postMessageHandler(event) {
  // Uncomment to debug
  // console.log("We've got a message!");
  // console.log("* Message:", event.data);
  // console.log("* Origin:", event.origin);
  // console.log("* Source:", event.source);

  // set document title
  window.document.title = event.data.title;

  // calculate new path based on the iframe src and the url provided in the message
  let newPath = removeSubstring(event.data.href + event.data.hash, iFrame().src);
  history.replaceState(event.data, event.data.title, newPath)
}

window.addEventListener("message", postMessageHandler, false);

window.addEventListener('DOMContentLoaded', () => {
  let gobiertoEmbed = document.querySelector("[gobierto-embed]");
  if (gobiertoEmbed === null) {
    throw "Div gobierto-embed not found!";
  }
  let iframe = document.createElement('iframe');
  iframe.src = gobiertoEmbed.attributes['gobierto-embed'].nodeValue + "?embed";
  iframe.id = 'gobierto-embed';
  iframe.allowfullscreen = true;
  iframe.style="width:100%; height:1400px;border:0px;";

  gobiertoEmbed.appendChild(iframe)
});
