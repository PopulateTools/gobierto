this.GobiertoPlans.PlansController = (function() {

    function PlansController() {}

    PlansController.prototype.show = function() {
      _loadPlan();
    };

    function _loadPlan() {

      // define the node root component
      Vue.component('node-root', {
        template: '#node-root-template',
        props: ['model'],
        data() {
          return {}
        },
        methods: {
          t(key) {
            return this.$root.t(key)
          },
          open() {
            // Trigger event
            this.$emit('selection', { ...this.model });

            // REVIEW: Revisar este bloque
            $('section.level_0 .js-img').velocity({flex: "0"});
            $('section.level_0 .js-info').velocity({padding: "1.5em"});
            $('section.level_0 .js-info h3, section.level_1 .js-info span').velocity({"font-size": "1.25rem" });

            $('section.level_0').velocity({flex: "0 0 25%"});
            $('section.level_1').velocity("transition.slideRightBigIn");
            $('section.level_1').css("display: flex");

          }
        }
      });

      // define the node list component
      Vue.component('node-list', {
        template: '#node-list-template',
        props: ['model'],
        data() {
          return {
            isOpen: false
          }
        },
        methods: {
          t(key) {
            return this.$root.t(key)
          },
          setActive: function() {
            let l = this.model.level;

            if (l === 1) {
              this.$emit('selection', { ...this.model });

              // hacky
              $('section.level_' + l).hide();
              $('section.level_' + (l + 1)).velocity("transition.slideRightBigIn");
              $('section.level_' + (l + 1)).css("display: flex");
            }

            if (l === 2) {
              this.$emit("toggle");
              this.isOpen = !this.isOpen;
            }
          }
        }
      });

      // define the table view component
      Vue.component('table-view', {
        template: '#table-view-template',
        props: ['model'],
        data() {
          return {}
        },
        methods: {
          t(key) {
            return this.$root.t(key)
          },
          percentFmt(key) {
            return this.$root.percentFmt(key)
          },
          dateFmt(key) {
            return this.$root.dateFmt(key)
          },
          getProject: function(project) {
            let l = this.model.level;
            this.$emit('selection', { ...project });

            // hacky
            $('section.level_' + l).hide();
            $('section.level_' + (l + 1)).velocity("transition.slideRightBigIn");
            $('section.level_' + (l + 1)).css("display: flex");
          }
        }
      });

      var app = new Vue({
        el: '#gobierto-planification',
        name: 'gobierto-planification',
        data: {
          json: {},
          activeNode: {},
          showTable: {},
          rootid: 0
        },
        created: function() {
          this.getJson();
        },
        watch: {
          activeNode: {
            handler: function(node) {
              this.showTable = {};
              this.isOpen(node.level);
            },
            deep: true
          }
        },
        computed: {
          detail() {
            if (!this.json.length) return {}
            let detail = {};
            detail = {
              roots: this.json.length,
              lines: _.flatten(_.map(this.json, 'children')).length,
              actions: this.json.length,
              projects: this.json.length
            };
            return detail
          }
        },
        methods: {
          getJson: function() {
            $.getJSON('/sandbox/data/planification.json', function(json) {
              this.json = json;
            }.bind(this));
          },
          t(key) {
            return key[I18n.locale] || key["es"] || key["en"] // fallback translations
          },
          percentFmt(value) {
            return (value / 100).toLocaleString(I18n.locale, { style: 'percent', maximumSignificantDigits: 4 })
          },
          dateFmt(date) {
            return new Date(date).toLocaleString(I18n.locale, { year: 'numeric', month: 'short', day: 'numeric' })
          },
          color() {
            return this.rootid % this.json.length + 1; // TODO: el mod no debe ser la longitud del array, sino, la de la variable de colores
          },
          setRootColor(index) {
            return index % this.json.length + 1;
          },
          setSelection(model) {
            this.activeNode = model;

            // To know the root node
            if (this.activeNode.level === 0) {
              // parse first position
              this.rootid = this.activeNode.uid.toString().charAt(0);
            }
          },
          isOpen(level) {
            return (level - 1) <= this.activeNode.level;
          },
          typeOf(val) {
            if (_.isString(val)) {
              return "string"
            } else if (_.isArray(val)) {
              return "array"
            }
            return "object";
          },
          toggle(i) {
            Vue.set(this.showTable, i, !(this.showTable[i]));
          },
          getParent() {
            this.activeNode = this.json[this.rootid].children[this.activeNode.parent];
          }
        }
      });

      //close everything
      $(document).click(function (e) {
        e.preventDefault();

        // if the target of the click isn't the container nor a descendant of the container REVIEW
        var container = $(".planification-content");
        if (!container.is(e.target) && container.has(e.target).length === 0) {
          app.activeNode = {};

          $('section.level_0').removeAttr('style');
          $('section.level_0 .js-img').removeAttr('style');
          $('section.level_0 .js-info').removeAttr('style');
          $('section.level_0 .js-info h3, section.level_1 .js-info span').removeAttr('style');
        }
      });
    };


    return PlansController;
  })();

  this.GobiertoPlans.plans_controller = new GobiertoPlans.PlansController;
