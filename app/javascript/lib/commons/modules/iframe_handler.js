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

$(document).on("turbolinks:load", () => handleIFramePageLoaded())
