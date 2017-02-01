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
  bullets: "Lista desordenada",
  byte: "Byte",
  bytes: "Bytes",
  captionPlaceholder: "Escribe un pie...",
  captionPrompt: "Añade un pie...",
  code: "Código",
  heading1: "Cabecera",
  indent: "Subir nivel",
  italic: "Cursiva",
  link: "Enlace",
  numbers: "Lista ordenada",
  outdent: "Bajar nivel",
  quote: "Cita",
  redo: "Re-hacer",
  remove: "Eliminar",
  strike: "Tachar",
  undo: "Deshacer",
  unlink: "Borrar enlace",
  urlPlaceholder: "Introduce la URL...",
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
