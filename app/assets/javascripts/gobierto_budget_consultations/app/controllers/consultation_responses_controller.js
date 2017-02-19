this.GobiertoBudgetConsultations.ConsultationResponsesController = (function() {
  function ConsultationResponsesController() {}

  ConsultationResponsesController.prototype.new = function() {
    _runConsultationApplication();
  };

  function _runConsultationApplication() {
    $(document).on('mouseenter', '.not-allowed', function(e){
      $(this).tipsy({offset: -40, className: 'tip-warning', fade: true, html: true, gravity: $.fn.tipsy.autoBounds(-18, 's'), opacity: 1, trigger: 'manual' });
      $(this).tipsy('show');
    });

    $(document).on('mouseenter', '.budget-status', function(e){
      $(this).tipsy({ offset: -20, className: 'tip-info', fade: true, html: true, gravity: 's', opacity: 1, trigger: 'manual' });
      $(this).tipsy('show');
    });

    $(document).on('mouseenter', '.consultation-status-error', function(e){
      $(this).tipsy({ className: 'tip-warning', fade: true, html: true, gravity: 's', opacity: 1, trigger: 'manual' });
      $(this).tipsy('show');
    });

    $(document).on('click', '[data-tipsy-close]', function(e){
      $('.not-allowed').tipsy('hide');
      $('.budget-status').tipsy('hide');
      $('.consultation-status-error').tipsy('hide');
    });

    var bus = new Vue();

    Vue.component('consultation-card', {
      props: ['card', 'active', 'figures'],
      template: '#card',
      computed: {
        iconForChoice: function(){
          if(this.card.choice === null) return;

          if(this.card.choice > 0) {
            return "fa-arrow-up";
          } else if (this.card.choice == 0){
            return "fa-check";
          } else if (this.card.choice < 0){
            return "fa-arrow-down";
          }
        }
      },
      methods: {
        setActive: function(card, e) {
          // Send the active event to the bus
          bus.$emit('active', card);

          // Save selected card
          var self = this;

          // Set individual card state
          card.toggleDesc = !card.toggleDesc;

          // Scroll to selected card
          // Set the description status
          $('body').animate({
            scrollTop: $(e.target).offset().top - 25
          }, 500, function() {
            // Once animation ends, check if the span is visible
            var isVisible = $(self.$el).find('.visibilityCheck').visible();

            if (isVisible !== 'undefined') {
              // If is not visible, set hidden to true
              card.hidden = isVisible ? false : true;
            }
          });

          // Reset value
          card.hidden = null;
        },
        beforeEnter: function (el) {
          el.style.opacity = 0
        },
        enter: function (el, done) {
          $(el).velocity("transition.slideDownIn", {duration: 200, delay: 100, complete: done});
        },
        leave: function (el, done) {
          $(el).velocity("transition.slideUpOut", {duration: 200, complete: done});
        }
      },
    });

    Vue.component('budget-box', {
      props: ['card', 'figures'],
      template: '#budget-box',
      methods: {
        showModal: function(d) {
          bus.$emit('open', d);
        },
        makeChoice: function(e) {
          e.preventDefault();
          bus.$emit('cardOptionChosen', $(e.target), this.card);
        }
      }
    });

    Vue.component('budget-calculator', {
      props: ['active', 'next', 'statusText', 'status'],
      template: '#budget-calculator',
      methods: {
        nextScreen: function(e){
          e.preventDefault();
          bus.$emit('cardOptionChosen', null, null);
        },
        submitConsultation: function(e){
          e.preventDefault();
          bus.$emit('submitConsultation');
        },
        showConsultationStatusError: function(e){
          e.preventDefault();
          console.log(e.target);
        }
      }
    });

    Vue.component('description-modal', {
      props: ['current'],
      template: '#description-modal',
      methods: {
        hideModal: function() {
          bus.$emit('close');
        }
      }
    });

    var app = new Vue({
      el: "#consultation-mobile-app",
      data: {
        figures: false,
        balance: true,
        active: false,
        modal: false,
        next: false,
        current: null,
        cards: [],
      },
      computed: {
        statusText: function(){
          return I18n.t('gobierto_budget_consultations.consultation_statuses.' + this.status);
        },
        status: function(){
          var possitiveCards = 0, negativeCards = 0;

          this.$data.cards.forEach(function(card){
            if(card.choice > 0) {
              possitiveCards++;
            } else if (card.choice < 0) {
              negativeCards++;
            }
          });
          if(possitiveCards === negativeCards){
            return 'balance';
          } else if (possitiveCards > negativeCards){
            return 'deficit';
          } else {
            return 'surplus';
          }
        }
      },
      methods: {
        fetchData: function(){
          var self = this;
          var url = $(self.$options.el).data('data-url');
          $.ajax({
            url: url,
            dataType: 'json',
            beforeSend: function(xhr){
              xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
            },
            success: function(response, textStatus, jqXHR){
              if(jqXHR.status == 200){
                Vue.set(self, 'cards', response);
              } else {
                // TODO: handle errors
              }
            },
          });
        },
        cardOptionChosenHandler: function($el, currentCard){
          this.choiceCardAndOpenNext($el, currentCard);
          var allSelected = true;
          app.$data.cards.forEach(function(card){
            if(card.choice === null)
              allSelected = false;
          });

          if(allSelected === true){
            Vue.set(app, 'next', true);
          }
        },
        choiceCardAndOpenNext: function($el, currentCard){
          if(currentCard !== null){
            app.$data.cards.forEach(function(card){
              if(currentCard === card) {
                card.choice = $el.data('value');
                card.toggleDesc = false;
              }
            });
          }
          var found = false;
          app.$data.cards.forEach(function(card){
            if(!found && card.choice === null){
              card.toggleDesc = true;
              found = true;
            }
          });
        },
        submitConsultation: function(){
          var self = this;
          var url = $(self.$options.el).data('submit-url');
          var data = app.$data.cards.map(function(card){
            return {
              item_id: card.id,
              selected_option: card.choice
            }
          });
          $.ajax({
            type: "POST",
            data: {
              consultation_response: {
                selected_options: data
              }
            },
            url: url,
            dataType: 'script',
            beforeSend: function(xhr){
              xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
            }
          });
        }
      },
      created: function() {
        this.fetchData();

        bus.$on('active', function(currentCard) {
          Vue.set(app, 'active', true);

          app.$data.cards.forEach(function(card){
            if(currentCard != card)
              card.toggleDesc = false;
          });
        });

        bus.$on('open', function(d) {
          Vue.set(app, 'current', d);
          Vue.set(app, 'modal', true);
        });

        bus.$on('close', function() {
          Vue.set(app, 'modal', false);
        });

        bus.$on('cardOptionChosen', this.cardOptionChosenHandler);

        bus.$on('submitConsultation', this.submitConsultation);
      },
    });
  }

  return ConsultationResponsesController;
})();

this.GobiertoBudgetConsultations.consultation_responses_controller = new GobiertoBudgetConsultations.ConsultationResponsesController;
