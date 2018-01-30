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
            $('section.level_1 .js-img').velocity({flex: "0"});
            $('section.level_1 .js-info').velocity({padding: "1.5em"});
            $('section.level_1 .js-info h3, section.level_1 .js-info span').velocity({"font-size": "1.25rem" });

            $('section.level_1').velocity({flex: "0 0 25%"});
            $('section.level_2').velocity("transition.slideRightBigIn");
            $('section.level_2').css("display: flex");

          }
        }
      });

      // define the node list component
      Vue.component('node-list', {
        template: '#node-list-template',
        props: ['model'],
        data() {
          return {
            open: false
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
              $('section.level_' + (l + 1)).hide();
              $('section.level_' + (l + 2)).velocity("transition.slideRightBigIn");
              $('section.level_' + (l + 2)).css("display: flex");
            }

            if (l === 2) {
              this.$emit("toggle");
              this.open = !this.open;
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
          getProject: function(project) {
            let l = this.model.level;
            this.$emit('selection', { ...this.model });

            // hacky
            $('section.level_' + (l + 1)).hide();
            $('section.level_' + (l + 2)).velocity("transition.slideRightBigIn");
            $('section.level_' + (l + 2)).css("display: flex");
          }
        }
      });

      new Vue({
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
        mounted: function () {
          //close everything
          // REVIEW: provoca error
          // $(document).click(function (e) {
          //   e.preventDefault();
          //
          //   // if the target of the click isn't the container nor a descendant of the container REVIEW
          //   var container = $(".planification-content");
          //   if (!container.is(e.target) && container.has(e.target).length === 0) {
          //     this.activeNode = {};
          //
          //     $('section.level_1').removeAttr('style');
          //     $('section.level_1 .js-img').removeAttr('style');
          //     $('section.level_1 .js-info').removeAttr('style');
          //     $('section.level_1 .js-info h3, section.level_1 .js-info span').removeAttr('style');
          //   }
          // }).bind(this);
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
          },
        },
        methods: {
          getJson: function() {
            $.getJSON('/sandbox/data/planification.json', function(json) {
              this.json = json;
            }.bind(this));
          },
          t(key) {
            return key[I18n.locale]
          },
          color(o) {
            if (this.isEmpty()) return 1;
            return this.rootid % 5 + 1;
          },
          setSelection(model) {
            this.activeNode = model;

            // To know the root node
            if (this.activeNode.level === 0) {
              this.rootid = this.activeNode.id
            }
          },
          isOpen(level) {
            return level <= this.activeNode.level;
          },
          isEmpty() {
            return _.isEmpty(this.activeNode);
          },
          toggle(i) {
            Vue.set(this.showTable, i, !(this.showTable[i]));
          },
          getParent() {
            this.activeNode = this.json[this.rootid].children[this.activeNode.parent];
          }
        }
      });
    };


    return PlansController;
  })();

  this.GobiertoPlans.plans_controller = new GobiertoPlans.PlansController;
