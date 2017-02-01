var element, elements, i, key, langMapping = {}, len, ref, selector, value;

ref = Trix.config.lang;
for (key in ref) {
  value = ref[key];
  selector = "button[title='" + value + "'], input[value='" + value + "'], input[placeholder='" + value + "']";
  elements = Trix.config.toolbar.content.querySelectorAll(selector);
  if (elements.length) {
    langMapping[key] = elements;
  }
}

Trix.config.lang = {
  bold: "Bold",
  bullets: "Bullets",
  byte: "Byte",
  bytes: "Bytes",
  captionPlaceholder: "Type a caption here…",
  captionPrompt: "Add a caption…",
  code: "Code",
  heading1: "Heading",
  indent: "Increase Level",
  italic: "Italic",
  link: "Link",
  numbers: "Numbers",
  outdent: "Decrease Level",
  quote: "Quote",
  redo: "Redo",
  remove: "Remove",
  strike: "Strikethrough",
  undo: "Undo",
  unlink: "Unlink",
  urlPlaceholder: "Enter a URL…",
  GB: "GB",
  KB: "KB",
  MB: "MB",
  PB: "PB",
  TB: "TB"
};

for (key in langMapping) {
  elements = langMapping[key];
  value = Trix.config.lang[key];
  for (i = 0, len = elements.length; i < len; i++) {
    element = elements[i];
    if (element.hasAttribute("title")) {
      element.setAttribute("title", value);
    }
    if (element.hasAttribute("value")) {
      element.setAttribute("value", value);
    }
    if (element.hasAttribute("placeholder")) {
      element.setAttribute("placeholder", value);
    }
    if (element.textContent) {
      element.textContent = value;
    }
  }
}

langMapping = null;
