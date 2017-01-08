this.GobiertoAdmin.DynamicContentComponent = (function() {
  function DynamicContentComponent() {}

  DynamicContentComponent.prototype.handle = function(recordNamespace) {
    handleAddChild(recordNamespace);
    handleAddRecord();
    handleCancelRecord();
    handleEditRecord();
    handleDeleteRecord();
  };

  function handleAddChild(recordNamespace) {
    var componentWrapper = $(".dynamic-content-wrapper");

    componentWrapper.on("click", "[data-behavior=add_child]", function(e) {
      e.preventDefault();

      var eventWrapper = $(this).closest(".dynamic-content-wrapper");
      var recordTemplate = eventWrapper.find(".dynamic-content-record-wrapper:visible:last");

      var fieldNameRegExp = new RegExp("\\[" + recordNamespace + "\\]\\[\\d+\\]", "i");
      var fieldIdRegExp = new RegExp("_" + recordNamespace + "_\\d+", "i");
      var contentBlockRecordRegExp = new RegExp("content-block-record-\\d+", "i");
      var randomId = new Date().getTime();
      var uniqueFieldName = "[" + recordNamespace + "][" + randomId + "]";
      var uniqueFieldId = "_" + recordNamespace + "_" + randomId;

      var clonedField = $(recordTemplate)
        .clone()
        .addClass("cloned-dynamic-content-record-wrapper")
        .removeClass(function() {
          var contentBlockRecordClass;

          $.each($(this).attr("class").split(" "), function(_, value) {
            if (contentBlockRecordRegExp.test(value)) {
              contentBlockRecordClass = value;
              return false;
            }
          });

          return contentBlockRecordClass;
        });

      clonedField.find("input, textarea, select").each(function() {
        var fieldName = $(this).attr("name");
        var fieldId = $(this).attr("id");

        if (fieldName !== undefined) {
          $(this).attr("name", fieldName.replace(fieldNameRegExp, uniqueFieldName));
        }

        if (fieldId !== undefined) {
          $(this).attr("id", fieldId.replace(fieldIdRegExp, uniqueFieldId));
        }

        if ($(this).attr("type") === "text") {
          $(this).val("");
        }
      });

      clonedField.find("label").each(function() {
        var labelFor = $(this).attr("for");

        $(this).attr("for", labelFor.replace(fieldIdRegExp, uniqueFieldId));
      });

      _switchToRecordForm(clonedField);

      $(recordTemplate).after(clonedField);
    });
  }

  function handleCancelRecord() {
    var componentWrapper = $(".dynamic-content-wrapper");

    componentWrapper.on("click", "[data-behavior=cancel_record]", function(e) {
      e.preventDefault();

      $(this).closest(".cloned-dynamic-content-record-wrapper").remove();

      var eventWrapper = $(this).closest(".dynamic-content-record-wrapper");

      _setRecordFormState(eventWrapper);
      _switchToRecordView(eventWrapper);
    });
  }

  function handleEditRecord() {
    var componentWrapper = $(".dynamic-content-wrapper");

    componentWrapper.on("click", "[data-behavior=edit_record]", function(e) {
      e.preventDefault();

      var eventWrapper = $(this).closest(".dynamic-content-record-wrapper");

      _switchToRecordForm(eventWrapper);
    });
  }

  function handleDeleteRecord() {
    var componentWrapper = $(".dynamic-content-wrapper");

    componentWrapper.on("click", "[data-behavior=delete_record]", function(e) {
      e.preventDefault();

      var eventWrapper = $(this).closest(".dynamic-content-record-wrapper");
      var deleteFlag = eventWrapper.find("input.destroy-content-block-record");

      deleteFlag.prop("checked", true);
      eventWrapper.hide();
    });
  }

  function handleAddRecord() {
    var componentWrapper = $(".dynamic-content-wrapper");

    componentWrapper.on("click", "[data-behavior=add_record]", function(e) {
      e.preventDefault();

      var eventWrapper = $(this).closest(".dynamic-content-record-wrapper");

      _setRecordViewState(eventWrapper);
      _switchToRecordView(eventWrapper);
    });
  }

  function _switchToRecordForm(wrapper) {
    wrapper.find(".dynamic-content-record-view").hide();
    wrapper.find(".dynamic-content-record-form").show();
  }

  function _switchToRecordView(wrapper) {
    wrapper.find(".dynamic-content-record-form").hide();
    wrapper.find(".dynamic-content-record-view").show();
  }

  function _setRecordViewState(wrapper) {
    var formState = wrapper.find(".content-block-field input").map(function() {
      return $(this).val();
    });

    wrapper.find(".dynamic-content-record-view .content-block-record-value").each(function(index) {
      $(this).html(formState[index]);
    });
  }

  function _setRecordFormState(wrapper) {
    var viewState = wrapper.find(".dynamic-content-record-view .content-block-record-value").map(function() {
      return $(this).html();
    });

    wrapper.find(".content-block-field input").each(function(index) {
      $(this).val(viewState[index]);
    });
  }

  return DynamicContentComponent;
})();

this.GobiertoAdmin.dynamic_content_component = new GobiertoAdmin.DynamicContentComponent;
