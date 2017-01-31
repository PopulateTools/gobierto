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
  bold: "Negrita",
  bullets: "Llista desordenada",
  byte: "Byte",
  bytes: "Bytes",
  captionPlaceholder: "Escriu un peu...",
  captionPrompt: "Afegeig un peu...",
  code: "Codi",
  heading1: "Capçalera",
  indent: "Pujar de nivell",
  italic: "Cursiva",
  link: "Enllaç",
  numbers: "Llista ordenada",
  outdent: "Baixar nivell",
  quote: "Cita",
  redo: "Tornar a fer",
  remove: "Elliminar",
  strike: "Tachar",
  undo: "Desfer",
  unlink: "Borrar enllaç",
  urlPlaceholder: "Introduix la URL...",
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
