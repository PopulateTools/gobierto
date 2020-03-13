"use strict";

// Removes the last / from an URL path
function removeSlice(path) {
  if (path[path.length - 1] === "/") {
    path = path.slice(0, -1);
  }
  return path;
}

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

// Removes embed parameter from an URL
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

// Adds embed parameter to an URL
function addEmbedParameter(url) {
  const parsedURL = parseURL(url);

  if (parsedURL.searchObject.hasOwnProperty("embed")) {
    return url;
  } else if (parsedURL.search === "") {
    return url + "?embed";
  } else {
    return url + "&embed";
  }
}


function postMessageHandler(event) {
  messages++;
  // Uncomment to debug
  // console.log("We've got a message!");
  // console.log("* Message:", event.data);
  // console.log("* Origin:", event.origin);
  // console.log("* Source:", event.source);

  // Set document title
  window.document.title = event.data.title;

  // Calculate new path based on the iframe src and the url provided in the message
  const iFramePath = toURLWithoutEmbedParameter(event.data.href);
  const newPath = basePath.replace(iFramePath, "") + iFramePath + event.data.hash;
  if (messages > 1) {
    history.replaceState(event.data, event.data.title, newPath);
  }

  // Scroll to top (not using ScrollToOptions because of browser incompatiblity)
  window.scrollTo(0, 0);
}

function getIFrameSrc(embedHost, embedPath, basePath) {
  // embedPath: [http://madrid.gobierto.test]/agendas
  // basePath:  [http://demo.alcobendas.org]/altos-cargos/
  // currentPath:
  //  1 - [http://demo.alcobendas.org]/altos-cargos/
  //  2 - [http://demo.alcobendas.org]/altos-cargos/agendas/
  //  3 - [http://demo.alcobendas.org]/altos-cargos/agendas/persona-1
  //  4 - [http://demo.alcobendas.org]/altos-cargos/partidos/

  let currentPath = removeSlice(window.location.pathname);
  let iFramePath;

  // scenarios 1 and 2
  if (currentPath === basePath || currentPath === basePath + embedPath) {
    iFramePath = embedPath;
  } else {
    iFramePath = currentPath.replace(basePath, "");
  }

  return addEmbedParameter(embedHost + iFramePath);
}

// The pathname of the page containing the iframe
let basePath;
let messages = 0;
// Listen for messages sent by the iFrame to update the URL
window.addEventListener("message", postMessageHandler, false);

window.addEventListener('DOMContentLoaded', function(){
  // Build the iFrame
  const gobiertoEmbed = document.querySelector("[gobierto-embed]");
  if (gobiertoEmbed === null) {
    throw "Div gobierto-embed not found!";
  }

  basePath = removeSlice(parseURL(gobiertoEmbed.attributes["base-path"].nodeValue).pathname);
  const parsedEmbedURL = parseURL(gobiertoEmbed.attributes["gobierto-embed"].nodeValue);
  const embedHost = parsedEmbedURL.protocol + "//" + parsedEmbedURL.host;
  const embedPath = removeSlice(parsedEmbedURL.pathname);

  const iframe = document.createElement('iframe');
  // The src attribute of the iFrame needs to have a "embed" parameter
  // so Gobierto won't render the layout and will send postMessages to update the URL
  iframe.src = getIFrameSrc(embedHost, embedPath, basePath);
  iframe.id = 'gobierto-embed';
  iframe.allowfullscreen = true;
  iframe.style = "width:100%; height:1400px;border:0px;";

  gobiertoEmbed.appendChild(iframe)
});
