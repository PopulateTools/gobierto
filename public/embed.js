"use strict";

// From https://www.abeautifulsite.net/parsing-urls-in-javascript
function parseURL(url) {
  let parser = document.createElement('a'),
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

function toURLWithoutEmbedParameter(url) {
  const parsedURL = parseURL(url);
  let queryString = "";
  if (parsedURL.search !== "") {
    let parameters = [];
    Object.keys(parsedURL.searchObject).forEach(function(key) {
      if (key !== "embed") {
        parameters.push(key + "=" + parsedURL.searchObject[key]);
      }
    });
    if (parameters.length) {
      queryString = "?" + parameters.join("&");
    }
  }

  return parsedURL.pathname + queryString + parsedURL.hash;
}

function addEmbedParameter(url) {
  const parsedURL = parseURL(url);
  if (parsedURL.searchObject.hasOwnProperty("embed")) {
    return url;
  }
  if (parsedURL.search === "") {
    return url + "?embed";
  } else {
    return url + "&embed";
  }
}


function postMessageHandler(event) {
  // Uncomment to debug
  // console.log("We've got a message!");
  // console.log("* Message:", event.data);
  // console.log("* Origin:", event.origin);
  // console.log("* Source:", event.source);

  // set document title
  window.document.title = event.data.title;

  // Calculate new path based on the iframe src and the url provided in the message
  const iFramePath = toURLWithoutEmbedParameter(event.data.href);
  const newPath = containerPathName + iFramePath + event.data.hash;
  history.replaceState(event.data, event.data.title, newPath)
}

// The pathname of the page containing the iframe
let containerPathName = window.location.pathname
if (containerPathName[containerPathName.length - 1] === "/") {
  containerPathName = containerPathName.slice(0, -1);
}

// Listen for messages sent by the iFrame to update the URL
window.addEventListener("message", postMessageHandler, false);

window.addEventListener('DOMContentLoaded', function(){
  // Build the iFrame
  const gobiertoEmbed = document.querySelector("[gobierto-embed]");
  if (gobiertoEmbed === null) {
    throw "Div gobierto-embed not found!";
  }
  let iframe = document.createElement('iframe');
  // The src attribute of the iFrame needs to have a "embed" parameter
  // so Gobierto won't render the layout and will send postMessages to update the
  // URL
  iframe.src = addEmbedParameter(gobiertoEmbed.attributes['gobierto-embed'].nodeValue);
  iframe.id = 'gobierto-embed';
  iframe.allowfullscreen = true;
  iframe.style = "width:100%; height:1400px;border:0px;";

  gobiertoEmbed.appendChild(iframe)
});

