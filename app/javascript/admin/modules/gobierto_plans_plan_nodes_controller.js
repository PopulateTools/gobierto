import 'jsgrid'

window.GobiertoAdmin.GobiertoPlansPlanNodesController = (function() {
  function GobiertoPlansPlanNodesController() {}

  var CustomDateField = function(config) {
    jsGrid.Field.call(this, config);
  };

  var LocalizedField = function(config) {
    jsGrid.Field.call(this, config);
  };

  var CategoryLevelField = function(config) {
    jsGrid.Field.call(this, config);
  };

  LocalizedField.prototype = new jsGrid.Field({

    locales: [I18n.locale],
    element_id: null,

    sorter: translated_sorter,

    itemTemplate: translated,
    insertTemplate: function() {
      let element = `<div id="lang-tabs-new-${this.element_id || Math.random().toString(36).substring(5)}" class="lang-tabs">`;
      for (var j in this.locales) {
        element +=`<input type="text" data-locale="${this.locales[j]}" class="${(I18n.locale == this.locales[j]) ? 'selected' : ''}">`
      }
      for (var i in this.locales) {
        element += `<span data-toggle="${this.locales[i]}" class="${(I18n.locale == this.locales[i]) ? 'selected' : ''}">${this.locales[i]}</span>`
      }
      element += '</div>'
      return this._insertPicker = $(element);
    },
    editTemplate: function(value) {
      let element = `<div id="lang-tabs-${this.element_id || Math.random().toString(36).substring(5)}" class="lang-tabs">`;
      for (var j in this.locales) {
        element +=`<input type="text" data-locale="${this.locales[j]}" value="${(value[this.locales[j]] || '')}" class="${(I18n.locale == this.locales[j]) ? 'selected' : ''}">`
      }
      for (var i in this.locales) {
        element += `<span data-toggle="${this.locales[i]}" class="${(I18n.locale == this.locales[i]) ? 'selected' : ''}">${this.locales[i]}</span>`
      }
      element += '</div>'
      return this._editPicker = $(element);
    },
    insertValue: function() {
      return generateTranslations(this._insertPicker);
    },
    editValue: function() {
      return generateTranslations(this._editPicker);
    }
  });

  CustomDateField.prototype = new jsGrid.Field({
    width: "10%",
    sorter: function(date1, date2) {
      return new Date(date1) - new Date(date2);
    },
    itemTemplate: function(value) {
      return value ? new Date(value).toLocaleDateString() : null;
    },
    insertTemplate: function() {
      return this._insertPicker = $('<input type="text">').datepicker().datepicker({ language: I18n.locale });
    },
    editTemplate: function(value) {
      var dateValue = value ? new Date(value) : new Date()
      var datepicker = $('<input type="text">').datepicker().datepicker({ startDate: dateValue, language: I18n.locale });
      if (value) datepicker.data('datepicker').selectDate(dateValue);
      return this._editPicker = datepicker;
    },
    insertValue: function() {
      return dateString(this._insertPicker.data("datepicker").selectedDates[0]);
    },
    editValue: function() {
      return dateString(this._editPicker.data("datepicker").selectedDates[0]);
    }
  });

  CategoryLevelField.prototype = new jsGrid.Field({
    itemTemplate: translated,

    sorter: translated_sorter,

    insertTemplate: function(value, item) {
      return this._insertPicker = categorySelect(value, item, this);
    },

    editTemplate: function(value, item) {
      return this._editPicker = categorySelect(value, item, this);
    },

    insertValue: function() {
      return this._insertPicker.val();
    },

    editValue: function() {
      return this._editPicker.val();
    }
  });

  function dateString(date) {
    return date ? new Date(date.getTime() - date.getTimezoneOffset()*60000).toISOString() : null;
  }

  function translated(value) {
    if (!value) return '';
    let text = value[I18n.locale];
    if (!text) {
      return Object.values(value).find(translation => !!translation);
    } else {
      return value[I18n.locale];
    }
  }

  function translated_sorter(value1, value2) {
    let translated1 = translated(value1)
    let translated2 = translated(value2)
    if (translated1) {
      return translated1.localeCompare(translated2)
    } else {
      return translated2 ? 1 : 0;
    }
  }

  function generateTranslations(picker) {
      let translations = {}
      picker.find("input").each(function() {
        translations[this.dataset.locale] = this.value;
      });
      return translations;
  }

  function nameValidator(locales) {
    return {
      validator: function(value) {
        return !Object.values(value).every(x => (x === null || x === ''));
      },
      message: I18n.t("gobierto_admin.gobierto_plans.plans.data.errors.missing_name"),
      param: locales
    };
  }

  function categorySelect(value, item, el) {
    let select = $('<select>');
    let selectId = function(level) { return 'category-' + level + '-' + (item ? item.id : 'new') };
    select.attr('id', selectId(el.level));

    if (item) {
      let options = el.categoriesVocabulary.filter(val => ( val.level === el.level && (!item.categories_hierarchy[el.level-1] || val.term_id === item.categories_hierarchy[el.level-1]) ));
      populateOpts(select, options, item.categories_hierarchy[el.level]);
    } else {
      if (el.level > 0) {
        select.prop('disabled', true)
      } else {
        let options = el.categoriesVocabulary.filter(val => ( val.level === el.level ));
        populateOpts(select, options, null);
      }
    }
    select.on("change", function() {
      if (el.level <= el.maxLevel) {
        for (let i = el.level + 1; i <= el.maxLevel; i++) {
          $('#' + selectId(i)).empty().prop('disabled', true);
        }
        let selection = $(this).val();
        if (selection) {
          let nextLevelOptions = el.categoriesVocabulary.filter(val => ( val.level === el.level + 1 && val.term_id === parseInt(selection, 10) ));
          let nextLevel = $('#' + selectId(el.level + 1));
          nextLevel.prop('disabled', false);
          populateOpts(nextLevel, nextLevelOptions, null);
        }
      }
    });
    return select;
  }

  function populateOpts(element, options, selection_id) {
    element.empty();
    element.prepend($('<option>').attr('value', '').text('--'));
    for(let i = 0; i < options.length; i++) {
      element.append($('<option>')
                     .attr('value', options[i].id)
                     .attr('selected', options[i].id === selection_id )
                     .text(translated(options[i].name_translations)));
    }
  }

  function categoryFields(options) {
    let fields = [];
    let maxLevel = options.categories_list.length-1;
    for (let i=0; i <= maxLevel; i++) {
      fields.push({
        name: "level_" + i,
        title: I18n.t("gobierto_admin.gobierto_plans.plans.data.category") + ' ' + i,
        type: "categoryLevelField",
        validate: {
          validator: function(value, item, param) {
            return (!param < i) || item['level_' + param]
          },
          message: I18n.t("gobierto_admin.gobierto_plans.plans.data.errors.missing_category"),
          param: maxLevel
        },
        categoriesVocabulary: options.categories_vocabulary,
        level: i,
        maxLevel: maxLevel
      });
    }
    return fields;
  }

  function _focusInsertMode() {
    let grid = $("#jsGrid")
    if (grid.jsGrid("option", "inserting")) {
      grid.jsGrid("option", "inserting", false)
    } else {
      grid.jsGrid("option", "inserting", true)
      $('.jsgrid-insert-row select').first().focus();
    }
  }

  jsGrid.fields.customDateField = CustomDateField;
  jsGrid.fields.localizedField = LocalizedField;
  jsGrid.fields.categoryLevelField = CategoryLevelField;
  jsGrid.ControlField.prototype._createGridButton = function(cls, tooltip, clickHandler) {
    let grid = this._grid;

    // Correspondance FontAwesome icons by action
    let map = {
      'edit': 'edit',
      'delete': 'trash',
      'mode insert-mode': '',
      'insert': 'check',
      'update': 'check',
      'cancel-edit': 'times',
    }

    let fa = map[cls.replace(new RegExp('jsgrid-', 'g'), '').replace(new RegExp('-button', 'g'), '')]
    let classname = `fa fa-${fa}`

    return $("<i>")
      .removeClass()
      .addClass(classname)
      .on("click", function(e) {
        clickHandler(grid, e);
      });
  };

  GobiertoPlansPlanNodesController.prototype.index = function(options) {

    $(document).on("click", "span[data-toggle]", function () {
      const lang = $(this).data("toggle")
      const parent = $(this).closest(".lang-tabs").attr("id")
      // hide others input fields
      $(`#${parent} input[data-locale=${lang}]`).addClass("selected")
      // display language selected
      $(`#${parent} input[data-locale!=${lang}]`).removeClass("selected")
      // mark/unmark language selected
      $(`#${parent} span[data-toggle=${lang}]`).addClass("selected")
      $(`#${parent} span[data-toggle!=${lang}]`).removeClass("selected")
    })

    $("#jsGrid").jsGrid({
      width: "100%",
      filtering: false,
      inserting: true,
      editing: true,
      sorting: true,
      paging: false,
      autoload: true,
      pageSize: 10,
      pageButtonCount: 5,
      noDataContent: I18n.t("gobierto_admin.gobierto_plans.plans.data.not_found"),
      confirmDeleting: true,
      deleteConfirm: I18n.t("gobierto_admin.gobierto_plans.plans.data.delete_confirm"),
      invalidMessage: I18n.t("gobierto_admin.gobierto_plans.plans.data.invalid_message"),
      loadMessage: I18n.t("gobierto_admin.gobierto_plans.plans.data.load_message"),
      controller: {
        loadData: function(filter) {
          return $.ajax({
            type: "GET",
            url: options.collection_path,
            data: filter
          });
        },
        insertItem: function(item) {
          return $.ajax({
            type: "POST",
            url: options.collection_path,
            data: item
          });
        },
        updateItem: function(item) {
          return $.ajax({
            type: "PUT",
            url: options.item_path + item.id,
            data: item
          });
        },
        deleteItem: function(item) {
          return $.ajax({
            type: "DELETE",
            url: options.item_path + item.id
          });
        }
      },

      onError: function(args) {
        window.alert(I18n.t("gobierto_admin.gobierto_plans.plans.data.invalid_message"))
      },

      fields: categoryFields(options).concat([
        {
          name: "name_translations",
          title: I18n.t("gobierto_admin.gobierto_plans.plans.data.name"),
          type: "localizedField",
          locales: options.locales,
          element_id: "name",
          validate: nameValidator(options.locales)
        },
        {
          name: "status_translations",
          title: I18n.t("gobierto_admin.gobierto_plans.plans.data.status"),
          type: "localizedField",
          element_id: "status",
          locales: options.locales
        },
        {
          name: "progress",
          title: I18n.t("gobierto_admin.gobierto_plans.plans.data.progress"),
          type: "number",
          width: "6%"
        },
        {
          name: "starts_at",
          title: I18n.t("gobierto_admin.gobierto_plans.plans.data.starts_at"),
          type: "customDateField",
          width: "10%"
        },
        {
          name: "ends_at",
          title: I18n.t("gobierto_admin.gobierto_plans.plans.data.ends_at"),
          type: "customDateField",
          width: "10%"
        },
        {
          name: "options_json",
          itemTemplate: function(value) {
            let maxLength = 100;
            if (value && value.length > maxLength) {
              return `${ value.substring(0, maxLength) }...`;
            } else {
              return value;
            }
          },
          title: I18n.t("gobierto_admin.gobierto_plans.plans.data.options"),
          type: "textarea"
        },
        {
          type: "control",
          editButton: true,
          deleteButton: true,
          modeSwitchButton: true,
          align: "center",
          width: "5%",
          filtering: false,
          inserting: true,
          editing: true,
          sorting: false,
          insertModeButtonTooltip: I18n.t("gobierto_admin.gobierto_plans.plans.data.insert_switch"),
          editButtonTooltip: I18n.t("gobierto_admin.gobierto_plans.plans.data.edit"),
          deleteButtonTooltip: I18n.t("gobierto_admin.gobierto_plans.plans.data.delete"),
          insertButtonTooltip: I18n.t("gobierto_admin.gobierto_plans.plans.data.insert"),
          updateButtonTooltip: I18n.t("gobierto_admin.gobierto_plans.plans.data.update"),
          cancelEditButtonTooltip: I18n.t("gobierto_admin.gobierto_plans.plans.data.cancel_edit")
        }
      ])
    });

    $(document).on("click", "a[data-insert]", function(e) {
      e.preventDefault()
      _focusInsertMode()
    })
  };

  return GobiertoPlansPlanNodesController;
})();

window.GobiertoAdmin.gobierto_plans_plan_nodes_controller = new GobiertoAdmin.GobiertoPlansPlanNodesController;
