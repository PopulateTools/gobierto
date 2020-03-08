"use strict";

function postMessageHandler(event) {
  // Uncomment to debug
  // console.log("We've got a message!");
  // console.log("* Message:", event.data);
  // console.log("* Origin:", event.origin);
  // console.log("* Source:", event.source);

  // Set document title
  window.document.title = event.data.title;

  // Calculate new path based on the iframe src and the url provided in the message
  let newPath = containerPathName + event.data.href + event.data.hash;
  history.replaceState(event.data, event.data.title, newPath)
}

// The pathname of the page containing the iframe
let containerPathName = window.location.pathname
if (containerPathName[containerPathName.length - 1] === "/") {
  containerPathName = containerPathName.slice(0, -1);
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

