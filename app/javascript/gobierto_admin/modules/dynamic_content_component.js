import Cleave from 'cleave.js'
import 'geocomplete'

window.GobiertoAdmin.DynamicContentComponent = (function() {
  function DynamicContentComponent() {}

  DynamicContentComponent.prototype.handle = function(wrapper, namespace) {
    handleAddChild(wrapper, namespace);
    handleAddRecord(wrapper);
    handleCancelRecord(wrapper);
    handleEditRecord(wrapper);
    handleDeleteRecord(wrapper);
  };

  function initializeRecordFields(wrapper) {
    var componentWrapper = $(wrapper || ".dynamic-content-wrapper");
    var componentLocale = componentWrapper.data("locale");

    _handleGeocompleteBehavior(componentWrapper.find("input[data-behavior=geocomplete]"));
    _handleDateType(componentWrapper.find("input[data-type=date]"), componentLocale);
    _handleCurrencyType(componentWrapper.find("input[data-type=currency]"));
  }

  function handleAddChild(wrapper, namespace) {
    var componentWrapper = $(wrapper || ".dynamic-content-wrapper");
    var componentLocale = componentWrapper.data("locale");

    componentWrapper.on("click", "[data-behavior=add_child]", function(e) {
      e.preventDefault();

      var eventWrapper = $(this).closest(".dynamic-content-wrapper");
      var recordTemplate = eventWrapper.find(".dynamic-content-record-wrapper:visible:last");

      var fieldNameRegExp = new RegExp("\\[" + namespace + "\\]\\[\\d+\\]", "i");
      var fieldIdRegExp = new RegExp("_" + namespace + "_\\d+", "i");
      var contentBlockRecordRegExp = new RegExp("content-block-record-\\d+", "i");
      var randomId = new Date().getTime();
      var uniqueFieldName = "[" + namespace + "][" + randomId + "]";
      var uniqueFieldId = "_" + namespace + "_" + randomId;

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

        _cleanupRecordField($(this));
        _initializeRecordField($(this), componentLocale);
      });

      clonedField.find("label").each(function() {
        var labelFor = $(this).attr("for");

        $(this).attr("for", labelFor.replace(fieldIdRegExp, uniqueFieldId));
      });

      $(recordTemplate).after(clonedField);
      // Display after render
      _switchToRecordForm(clonedField);

      clonedField.find('[data-remove-component="true"]').remove();
      clonedField.find('[type=checkbox][data-clear-value="true"]').prop('checked', false);
      clonedField.find("input:visible:first").focus();
      clonedField.find('span[data-class="attachment_link_placeholder"]').removeClass('hidden');
      clonedField.find('span[data-class="attachment_link_placeholder"]').html('-');
    });
  }

  function handleCancelRecord(wrapper) {
    var componentWrapper = $(wrapper || ".dynamic-content-wrapper");

    componentWrapper.on("click", "[data-behavior=cancel_record]", function(e) {
      e.preventDefault();

      $(this).closest(".cloned-dynamic-content-record-wrapper").remove();

      var eventWrapper = $(this).closest(".dynamic-content-record-wrapper");

      _setRecordFormState(eventWrapper);
      _switchToRecordView(eventWrapper);
    });
  }

  function handleEditRecord(wrapper) {
    var componentWrapper = $(wrapper || ".dynamic-content-wrapper");

    componentWrapper.on("click", "[data-behavior=edit_record]", function(e) {
      e.preventDefault();

      var eventWrapper = $(this).closest(".dynamic-content-record-wrapper");

      _switchToRecordForm(eventWrapper);
    });
  }

  function handleDeleteRecord(wrapper) {
    var componentWrapper = $(wrapper || ".dynamic-content-wrapper");

    componentWrapper.on("click", "[data-behavior=delete_record]", function(e) {
      e.preventDefault();

      var eventWrapper = $(this).closest(".dynamic-content-record-wrapper");
      var deleteFlag = eventWrapper.find("input.destroy-content-block-record");

      deleteFlag.prop("checked", true);
      eventWrapper.hide();
    });
  }

  function handleAddRecord(wrapper) {
    var componentWrapper = $(wrapper || ".dynamic-content-wrapper");

    componentWrapper.on("click", "[data-behavior=add_record]", function(e) {
      e.preventDefault();

      var eventWrapper = $(this).closest(".dynamic-content-record-wrapper");

      _setRecordViewState(eventWrapper);
      _switchToRecordView(eventWrapper);

      var attachment_input = eventWrapper.find('input[type="file"]');
      var delete_attachment = eventWrapper.find('[data-behavior="remove_attachment"]');
      var attachmentLink = eventWrapper.find('a[data-class="attachment_link"]');
      var attachmentLinkPlaceholder = eventWrapper.find('span[data-class="attachment_link_placeholder"]');

      if (delete_attachment.is(':checked')) {
        attachmentLink.hide();
        attachmentLinkPlaceholder.show();
      } else if (attachmentLink.length) {
        attachmentLink.show();
        attachmentLinkPlaceholder.hide();
      }

      if (attachment_input.val() !== '' && "undefined" !== typeof attachment_input.val()) {
        var attachment_name = attachment_input.val().replace(/C:\\fakepath\\/i, '');
        attachmentLink.hide();
        attachmentLinkPlaceholder.html(attachment_name);
      }
    });
  }

  function _cleanupRecordField(selector) {
    if ( (selector.attr("type") === "hidden") && !(selector.attr("data-clear-value") === "true") ) {
      return true;
    }

    if (selector.attr("type") === "select") {
      selector.find("option:selected").prop("selected", false);
    } else {
      selector.val("");
    }
  }

  function _initializeRecordField(selector, locale) {
    if (selector.data("behavior") === "geocomplete") {
      _handleGeocompleteBehavior(selector);
    }

    if (selector.data("type") === "date") {
      _handleDateType(selector, locale);
    }

    if (selector.data("type") === "currency") {
      _handleCurrencyType(selector);
    }
  }

  function _handleGeocompleteBehavior(selector) {
    if (!selector.length) {
      return true;
    }

    selector.geocomplete({
      details: ".content-block-field",
      detailsAttribute: "data-geo",
      componentRestrictions: { country: "es" }
    });
  }

  function _handleDateType(selector, locale) {
    if (!selector.length) {
      return true;
    }

    selector.datepicker({
      language: locale,
      autoClose: true,
      onSelect: function onSelect(a, b, instance) {
        $(instance.el).trigger("datepicker-change");
      }
    });
  }

  function _handleCurrencyType(selector) {
    if (!selector.length) {
      return true;
    }

    new Cleave(selector, {
      numeral: true,
      numeralThousandsGroupStyle: "thousand",
      numeralDecimalMark: I18n.t('number.currency.format.separator'),
      delimiter: I18n.t('number.currency.format.delimiter')
    });
  }

  function _switchToRecordForm(wrapper) {
    initializeRecordFields(wrapper);

    wrapper.find(".dynamic-content-record-view").hide();
    wrapper.find(".dynamic-content-record-form").show();
    wrapper.find(".dynamic-content-record-form input:visible:first").focus();
  }

  function _switchToRecordView(wrapper) {
    wrapper.find(".dynamic-content-record-form").hide();
    wrapper.find(".dynamic-content-record-view").show();
  }

  function _setRecordViewState(wrapper) {
    var formState = wrapper.find(".content-block-field input, select option:selected").map(function() {
      return $(this).text() || $(this).val();
    });

    wrapper.find(".dynamic-content-record-view .content-block-record-value").each(function(index) {
      var fieldText = formState[index];
      var urlPattern = new RegExp('^https?://.*$')

      if (urlPattern.test(fieldText)) {
        $(this).html('<a href="' + fieldText + '">' + fieldText + '</a>');
      } else {
        $(this).html(fieldText);
      }
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

window.GobiertoAdmin.dynamic_content_component = new GobiertoAdmin.DynamicContentComponent;
