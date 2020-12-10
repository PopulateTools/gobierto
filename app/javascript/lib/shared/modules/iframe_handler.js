// iFrame communication
export function handleIFramePageLoaded() {
  console.log(window.location !== window.parent.location, window.location, window.parent.location);
  // If the current page has been loaded in an iframe
  if (window.location !== window.parent.location) {
    // Send a message to the iframe container with the URL (href + hash) and
    // the title of the document
    let message = {
      href: window.location.href,
      hash: window.location.hash,
      title: window.document.title
    };
    console.log("Posting message:", message);
    window.parent.postMessage(message, '*');
  }
}
