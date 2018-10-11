import { isMobile } from 'lib/shared'
import Vue from 'vue'
Vue.config.productionTip = false

import 'sticky-kit/dist/sticky-kit.js'

window.GobiertoBudgetConsultations.ConsultationResponsesController = (function() {
  function ConsultationResponsesController() {}

  ConsultationResponsesController.prototype.new = function() {
    _runConsultationApplication();
  };

  function _runConsultationApplication() {
    $(document).on('click', '.not-allowed', function(){
      $(this).tipsy({offset: -40, className: 'tip-warning', fade: true, html: true, gravity: isMobile() ? 'sw' : 's', opacity: 1, trigger: 'manual' });
      $(this).tipsy('show');
    });

    $(document).on('click', '.budget-status-figure', function(){
      $(this).tipsy({ offset: isMobile() ? -20 : 20, className: 'tip-info', fade: true, html: true, gravity: isMobile() ? 's' : 'n', opacity: 1, trigger: 'manual' });
      $(this).tipsy('show');
    });

    $(document).on('click', '.consultation-status-error', function(){
      $(this).tipsy({ className: 'tip-warning', fade: true, html: true, gravity: 's', opacity: 1, trigger: 'manual' });
      $(this).tipsy('show');
    });

    $(document).on('click', '[data-tipsy-close]', function(){
      $('.tipsy').remove();
    });

    var bus = new Vue();

    Vue.component('card-description', {
      props: ['card', 'figures'],
      template: (isMobile() ? '#card-description-mobile' : '#card-description-desktop'),
      methods: {
        beforeEnter: function (el) {
          el.style.opacity = 0
        },
        enter: function (el) {
          $(el).velocity("transition.slideDownIn", {duration: 200, delay: 250, complete: function(){
            $('body').animate({
              scrollTop: $(el).offset().top - 85
            }, 400);
          }});
        },
        leave: function (el) {
          $(el).velocity("transition.slideUpOut", {duration: 200, complete: function(){}});
        }
      }
    });

    Vue.component('consultation-card', {
      props: ['card', 'active', 'figures'],
      template: (isMobile() ? '#card-mobile' : '#card-desktop'),
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
        setActive: function(card) {
          $('.tipsy').remove();

          // Send the active event to the bus
          bus.$emit('active', card);

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
      props: ['active', 'next', 'statusText', 'status', 'statusClass'],
      template: '#budget-calculator',
      methods: {
        nextScreen: function(e){
          e.preventDefault();
          bus.$emit('cardOptionChosen', null, null);
        },
        submitConsultation: function(e){
          e.preventDefault();
          $(e.target).prop('disabled', true);
          bus.$emit('submitConsultation');
        },
        showConsultationStatusError: function(e){
          e.preventDefault();
        }
      },
      updated: function(){
        var $el = $('[data-status-explanation]');
        $el.attr('title', $el.attr('title_' + this.status));
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
        statusDifference: 0,
        cards: [],
      },
      computed: {
        statusText: function(){
          return I18n.t('gobierto_budget_consultations.consultation_statuses.' + this.status);
        },
        statusClass: function(){
          // Track difference between status
          // The status class variable maxes out at 4 to be applied to the card class
          var classId = this.statusDifference;

          if (classId > 4)  classId = 4;
          if (classId < -4) classId = -4;

          if (classId < 0) return 'surplus surplus-' + Math.abs(classId);
          if (classId > 0) return 'deficit deficit-' + Math.abs(classId);
        },
        status: function(){
          if(this.statusDifference === 0) return 'balance';
          if (this.statusDifference < 0)  return 'surplus';
          return 'deficit';
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

          if(allSelected){
            Vue.set(app, 'next', true);
            $('.consultation-confirm').css('width', $('.description').width() - 79);

            $('body').animate({
              scrollTop: $(app.$el).offset().top - 25
            }, 500);
          }
        },
        choiceCardAndOpenNext: function($el, currentCard){
          if(currentCard !== null){
            var positiveCards = 0;
            var negativeCards = 0;
            app.$data.cards.forEach(function(card){
              if(currentCard === card) {
                card.choice = $el.data('value');
                card.toggleDesc = false;
              }
              if(card.choice > 0) {
                positiveCards++;
              } else if (card.choice < 0) {
                negativeCards++;
              }
            });
          }
          this.statusDifference = positiveCards - negativeCards;

          var found = false;
          app.$data.cards.forEach(function(card){
            if(!found && card.choice === null){
              card.toggleDesc = true;
              found = true;
              bus.$emit('active', card);
            }
          });
        },
        submitConsultation: function(e){
          if(e !== undefined)
            $(e.target).prop('disabled', true);

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

          if (app.$data.next) {
            $('.consultation-confirm').addClass('slim');
            $('.slim').css('top', 0);
          }

          var $target = $('[data-card-id="'+currentCard.id+'"]');
          var $targetDescription = $('[data-card-description-id="'+currentCard.id+'"]');
          var offset = 0;
          if($targetDescription.length){
            if ($('.card-wrapper').css('top') === 'auto') {
              offset = $target.offset().top - 220;
            } else {
              offset = $target.offset().top - 250;
            }
            $targetDescription.css({ top: offset + 'px' });
          }
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

window.GobiertoBudgetConsultations.consultation_responses_controller = new GobiertoBudgetConsultations.ConsultationResponsesController;
