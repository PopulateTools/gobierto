export { applyPluginStyles }

function applyPluginStyles(element, plugin_name_hint) {
  element.wrap("<div class='v_container'><div class='v_el v_el_level v_el_full_content'></div></div>");
  element.find("div.custom_field_value").addClass(`${plugin_name_hint}_table`)
  element.find("div.data-container")
         .addClass("slickgrid-container")
         .css({ width: "100%", height: "500px" });
}
