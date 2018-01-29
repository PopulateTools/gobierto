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

            // REVIEW: Revisar este bloque
            $('section.level_1 .js-img').velocity({flex: "0"});
            $('section.level_1 .js-info').velocity({padding: "1.5em"});
            $('section.level_1 .js-info h3, section.level_1 .js-info span').velocity({"font-size": "1.25rem" });

            $('section.level_1').velocity({flex: "0 0 25%"});
            $('section.level_2').velocity("transition.slideRightBigIn");
            $('section.level_2').css("display: flex");

            this.$emit('increment', this.model);
          }
        }
      });

      // define the node list component
      Vue.component('node-list', {
        template: '#node-list-template',
        props: ['model'],
        data() {
          return {
            showTable: false
          }
        },
        methods: {
          expand: function() {

            let l = this.model.level;

            if (l === 1) {
              this.$root.activeNode.lines = this.model;
              // hacky
              $('section.level_' + (l + 1)).hide();
              // $('section.level_' + (l + 2)).velocity("transition.slideRightBigIn");
              $('section.level_' + (l + 2)).css("display: flex");
            }

            if (l === 2) this.showTable = !this.showTable;
          }
        }
      });

      var app = new Vue({
        el: '#gobierto-planification',
        name: 'gobierto-planification',
        data() {
          return {
            json: {},
            activeNode: {},
            roots: false,
            lines: false
          }
        },
        created: function() {
          this.getJson();
        },
        mounted: function () {
          //close everything
          $(document).click(function (e) {
            e.preventDefault();

            // if the target of the click isn't the container nor a descendant of the container REVIEW
            var container = $(".planification-content");
            if (!container.is(e.target) && container.has(e.target).length === 0) {

              // reset activeNode properties
              // for (let prop in this.activeNode) {
              //   if (this.activeNode.hasOwnProperty(prop)) {
              //     prop = undefined;
              //   }
              // }

              $('section.level_1').removeAttr('style');
              $('section.level_1 .js-img').removeAttr('style');
              $('section.level_1 .js-info').removeAttr('style');
              $('section.level_1 .js-info h3, section.level_1 .js-info span').removeAttr('style');
            }
          }).bind(this);
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
            return 1
            // return this.activeNode[o].id % 5 + 1
          },
          setSelection(model) {
            this.roots = true;
            this.activeNode = model;
          },
          isEmpty(o) {
            return _.isEmpty(this.activeNode[o])
          }
        }
      });
    };

    return PlansController;
  })();

  this.GobiertoPlans.plans_controller = new GobiertoPlans.PlansController;
