function sendMessageToIframe() {
  // Send a message to the iframe container with the URL (href + hash) and
  // the title of the document
  let message = {
    href: window.location.href,
    hash: window.location.hash,
    title: window.document.title
  };
  window.parent.postMessage(message, '*');
}

// Static initialization
$(document).on("turbolinks:load", function() {
  if (window.location !== window.parent.location) {
    sendMessageToIframe();
  }
});
