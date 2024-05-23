import { GlobalEditorLock } from 'slickgrid';

export function applyPluginStyles(element, plugin_name_hint) {
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

export var defaultSlickGridOptions = {
  editable: true,
  enableAddRow: true,
  enableCellNavigation: true,
  asyncEditorLoading: false,
  enableColumnReorder: false,
  autoEdit: true,
  forceFitColumns: true,
  autoHeight: true
}

export function preventLosingCurrentEdit() {
  $(document).click(function(e) {
    // Avoid closing datepicker if we're navigating throught it
    if ($(e.target).closest(".datepicker--nav-action,.datepicker--nav-title,.datepicker--cells-months,.datepicker--cells-years").length > 0) return

    if ($(e.target).parents(".plugin_field").length == 0) {
      var lock = GlobalEditorLock;
      if (lock.isActive()) lock.commitCurrentEdit()
    }
  })
}
