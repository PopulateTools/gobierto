export { applyPluginStyles, defaultSlickGridOptions }

function applyPluginStyles(element, plugin_name_hint) {
  element.wrap(`
    <div class='v_container'>
      <div class='v_el v_el_level v_el_full_content' style='padding: 20px'>
      </div>
    </div>`);

  element.find("div.custom_field_value").addClass(`${plugin_name_hint}_table`)
  element.find("div.data-container")
         .addClass("slickgrid-container")
         .css({ width: "100%", "min-height": "150" });
}

var defaultSlickGridOptions = {
  editable: true,
  enableAddRow: true,
  enableCellNavigation: true,
  asyncEditorLoading: false,
  enableColumnReorder: false,
  autoEdit: true,
  autoHeight: true
}
