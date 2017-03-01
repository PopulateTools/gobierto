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

    $(document).on('mouseenter', '.budget-status-figure', function(e){
      $(this).tipsy({ offset: isMobile() ? -20 : 20, className: 'tip-info', fade: true, html: true, gravity: isMobile() ? 's' : $.fn.tipsy.autoBounds(-20, 'n'), opacity: 1, trigger: 'manual' });
      $(this).tipsy('show');
    });
    
    $(document).on('mouseenter', '.consultation-status-error', function(e){
      $(this).tipsy({ className: 'tip-warning', fade: true, html: true, gravity: 's', opacity: 1, trigger: 'manual' });
      $(this).tipsy('show');
    });

    $(document).on('click', '[data-tipsy-close]', function(e){
      $('.tipsy').remove();
    });

    var bus = new Vue();

    Vue.component('card-description', {
      props: ['card', 'figures'],
      template: (isMobile() ? '#card-description-mobile'  : '#card-description-desktop'),
      methods: {
        beforeEnter: function (el) {
          el.style.opacity = 0
        },
        enter: function (el, done) {
          $(el).velocity("transition.slideDownIn", {duration: 200, delay: 100, complete: done});
        },
        leave: function (el, done) {
          $(el).velocity("transition.slideUpOut", {duration: 200, complete: done});
        }
      }
    });

    Vue.component('consultation-card', {
      props: ['card', 'active', 'figures'],
      template: (isMobile() ? '#card-mobile'  : '#card-desktop'),
      computed: {
        iconForChoice: function(){
          if(this.card.choice === null) return;

          if(this.card.choice > 0) {
            return "fa-arrow-up";
          } else if (this.card.choice == 0){
            return "fa-circle";
          } else if (this.card.choice < 0){
            return "fa-arrow-down";
          }
        }
      },
      methods: {
        setActive: function(card, e) {
          $('.tipsy').remove();

          // Send the active event to the bus
          bus.$emit('active', card);

          // Save selected card
          var self = this;

          card.toggleDesc = !card.toggleDesc;

          // Reset value
          card.hidden = null;

          // Stick it
          $(".desktop .consultation-info").stick_in_parent();
        }
      }
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
          $('.tipsy').remove();
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
      el: (isMobile() ? "#consultation-mobile-app" : "#consultation-desktop-app"),
      data: {
        figures: false,
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
            $('body').animate({
              scrollTop: $(app.$el).offset().top - 25
            }, 500);
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
              bus.$emit('active', card);
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
        $(this.$options.el).show();
        this.fetchData();

        bus.$on('active', function(currentCard) {
          Vue.set(app, 'active', true);

          app.$data.cards.forEach(function(card){
            if(currentCard != card)
              card.toggleDesc = false;
          });

          var $target = $('[data-card-id="'+currentCard.id+'"]');
          var $targetDescription = $('[data-card-description-id="'+currentCard.id+'"]');
          if($targetDescription.length){
            var offset = $target.offset().top - 200;
            $targetDescription.css({ top: offset + 'px' });
          }

          window.setTimeout(function(){
            // Scroll to selected card
            // Set the description status
            $('body').animate({
              scrollTop: $target.offset().top - (isMobile() ? 25 : 85)
            }, 300, function() {
              // Set individual card state
              if(isMobile()){
                // Once animation ends, check if the span is visible
                var isVisible = $target.find('.visibilityCheck').visible();

                if (isVisible !== 'undefined') {
                  // If is not visible, set hidden to true
                  currentCard.hidden = isVisible ? false : true;
                }
              }
            });
          }, (isMobile() ? 250 : 0));
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
