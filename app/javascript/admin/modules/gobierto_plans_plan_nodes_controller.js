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

    locales: ["es"],

    itemTemplate: translated,
    insertTemplate: function(value) {
      var element = '';
      for (var i in this.locales) {
        element += '<span class="indication">' + this.locales[i] + '</span> <input type="text" data-locale="' + this.locales[i] +'">';
      }
      return this._insertPicker = $(element);
    },
    editTemplate: function(value) {
      var element = '';
      for (var i in this.locales) {
        element += '<span class="indication">' + this.locales[i] + '</span> <input type="text" data-locale="' + this.locales[i] +'" value="' + (value[this.locales[i]] || '') + '">';
      }
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
    sorter: function(date1, date2) {
      return new Date(date1) - new Date(date2);
    },
    itemTemplate: function(value) {
      return value ? new Date(value).toLocaleDateString() : null;
    },
    insertTemplate: function(value) {
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
    itemTemplate: function(value, item) {
      return translated(this.categoriesVocabulary.find(val => (val.id == item.categories_hierarchy[this.level])).name_translations);
    },

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
  };

  function generateTranslations(picker) {
      translations = {}
      picker.filter("input").each(function(e) {
        translations[this.dataset.locale] = this.value;
      });
      return translations;
  };

  function nameValidator(locales) {
    return {
      validator: function(value, item, param) {
        return !Object.values(value).every(x => (x === null || x === ''));
      },
      message: I18n.t("gobierto_admin.gobierto_plans.plans.data.errors.missing_name"),
      param: locales
    };
  };

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
  };

  function populateOpts(element, options, selection_id) {
    element.empty();
    element.prepend($('<option>').attr('value', '').text('--'));
    for(let i = 0; i < options.length; i++) {
      element.append($('<option>')
                     .attr('value', options[i].id)
                     .attr('selected', options[i].id === selection_id )
                     .text(translated(options[i].name_translations)));
    }
  };

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
  };

  jsGrid.fields.customDateField = CustomDateField;
  jsGrid.fields.localizedField = LocalizedField;
  jsGrid.fields.categoryLevelField = CategoryLevelField;

  GobiertoPlansPlanNodesController.prototype.index = function(options) {
    $("#jsGrid").jsGrid({
      height: "80%",
      width: "100%",
      filtering: true,
      inserting: true,
      editing: true,
      sorting: true,
      paging: false,
      autoload: true,
      pageSize: 10,
      pageButtonCount: 5,
      deleteConfirm: "Do you really want to delete node?",
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

      fields: categoryFields(options).concat([
        { name: "name_translations", title: I18n.t("gobierto_admin.gobierto_plans.plans.data.name"), type: "localizedField", locales: options.locales, validate: nameValidator(options.locales) },
        { name: "status_translations", title: I18n.t("gobierto_admin.gobierto_plans.plans.data.status"), type: "localizedField", locales: options.locales },
        { name: "progress", title: I18n.t("gobierto_admin.gobierto_plans.plans.data.progress"), type: "number" },
        { name: "starts_at", title: I18n.t("gobierto_admin.gobierto_plans.plans.data.starts_at"), type: "customDateField" },
        { name: "ends_at", title: I18n.t("gobierto_admin.gobierto_plans.plans.data.ends_at"), type: "customDateField" },
        { name: "options_json", title: I18n.t("gobierto_admin.gobierto_plans.plans.data.options"), type: "textarea" },
        { type: "control" }
      ])
    });
  };

  return GobiertoPlansPlanNodesController;
})();

window.GobiertoAdmin.gobierto_plans_plan_nodes_controller = new GobiertoAdmin.GobiertoPlansPlanNodesController;
