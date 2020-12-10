// iFrame communication
export function handleIFramePageLoaded() {
  // If the current page has been loaded in an iframe
  if (window.location !== window.parent.location) {
    // Send a message to the iframe container with the URL (href + hash) and the title of the document
    let message = {
      type: 'gobiertoIframeUrl',
      href: window.location.href,
      hash: window.location.hash,
      title: window.document.title
    };
    window.parent.postMessage(message, '*');
  }
}

export function iFrameGobiertoMessageHandler(event) {
  if(event.data.type !== 'gobiertoIframeStyles') {
    return;
  }

  // Uncomment to debug
  // console.log("We've got a message in Gobierto!");
  // console.log("* Message:", event.data);
  // console.log("* Origin:", event.origin);
  // console.log("* Source:", event.source);
  let head = document.getElementsByTagName("head")[0]
  head.innerHTML += event.data.styles;
}
