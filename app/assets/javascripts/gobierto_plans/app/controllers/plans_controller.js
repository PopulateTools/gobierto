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
          return {}
        },
        methods: {
          expand: function() {
            let l = this.model.level;

            if (l === 1) {
              this.$emit('selection', { ...this.model });

              // hacky
              $('section.level_' + (l + 1)).hide();
              $('section.level_' + (l + 2)).velocity("transition.slideRightBigIn");
              $('section.level_' + (l + 2)).css("display: flex");
            }

            if (l === 2) this.$emit("toggle");
          }
        }
      });

      new Vue({
        el: '#gobierto-planification',
        name: 'gobierto-planification',
        data: {
          json: {},
          activeNode: {},
          toggle: false
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
          color(o) {
            if (this.isEmpty()) return 1;
            return this.activeNode.id % 5 + 1;
          },
          setSelection(model) {
            this.activeNode = model;
          },
          isOpen(level) {
            return level <= this.activeNode.level;
          },
          isEmpty() {
            return _.isEmpty(this.activeNode);
          }
        }
      });
    };

    return PlansController;
  })();

  this.GobiertoPlans.plans_controller = new GobiertoPlans.PlansController;
