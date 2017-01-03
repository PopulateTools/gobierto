this.GobiertoAdmin.DynamicContentComponent = (function() {
  function DynamicContentComponent() {}

  DynamicContentComponent.prototype.handle = function(recordNamespace) {
    _handleAddChild(recordNamespace);
  };

  function _handleAddChild(recordNamespace) {
    var componentWrapper = $(".dynamic-content-wrapper");

    componentWrapper.on("click", "[data-behavior=add_child]", function(e) {
      e.preventDefault();

      var eventWrapper = $(this).closest(".dynamic-content-wrapper");
      var recordTemplate = eventWrapper.find(".dynamic-content-record-wrapper:last");

      var fieldNameRegex = new RegExp("\\[" + recordNamespace + "\\]\\[\\d+\\]", "i");
      var fieldIdRegex = new RegExp("_" + recordNamespace + "_\\d+", "i");
      var randomId = new Date().getTime();
      var uniqueFieldName = "[" + recordNamespace + "][" + randomId + "]";
      var uniqueFieldId = "_" + recordNamespace + "_" + randomId;

      var clonedField = $(recordTemplate).clone();

      clonedField.find("input, textarea, select").each(function() {
        var fieldName = $(this).attr("name");
        var fieldId = $(this).attr("id");

        if (fieldName !== undefined) {
          $(this).attr("name", fieldName.replace(fieldNameRegex, uniqueFieldName));
        }

        if (fieldId !== undefined) {
          $(this).attr("id", fieldId.replace(fieldIdRegex, uniqueFieldId));
        }

        if ($(this).attr("type") === "text") {
          $(this).val("");
        }
      });

      clonedField.find("label").each(function() {
        var labelFor = $(this).attr("for");

        $(this).attr("for", labelFor.replace(fieldIdRegex, uniqueFieldId));
      });

      $(recordTemplate).after(clonedField);
    });
  }

  return DynamicContentComponent;
})();

this.GobiertoAdmin.dynamic_content_component = new GobiertoAdmin.DynamicContentComponent;
