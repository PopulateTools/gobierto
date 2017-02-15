$(document).on('ready page:change', function() {
  $('.not-allowed').tipsy({offset: -40, className: 'tip-warning', live: true, fade: true, html: true, gravity: $.fn.tipsy.autoBounds(-18, 's'), opacity: 1});
  $('.budget-status').tipsy({offset: -20, className: 'tip-info', live: true, fade: true, html: true, gravity: 's', opacity: 1});

  var bus = new Vue();

  Vue.component('consultation-card', {
    props: ['card', 'active'],
    template: '#card',
    methods: {
      setActive: function(d, e) {
        // Send the active event to the bus
        bus.$emit('active');

        // Save selected card
        var that = this;

        // Set individual card state
        d.toggleDesc = !d.toggleDesc;

        // Scroll to selected card
        // Set the description status
        // $('body').animate({
        //   scrollTop: $(e.target).offset().top - 25
        // }, 300, function() {
        //   // Once animation ends, check if the span is visible
        //   var isVisible = $(that.$el).find('.visibilityCheck').visible();
        //
        //   if (isVisible !== 'undefined') {
        //     // If is not visible, set hidden to true
        //     d.hidden = isVisible ? false : true;
        //   }
        // });

        // Reset value
        d.hidden = null;
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
    }
  });

  Vue.component('budget-box', {
    props: ['card'],
    template: '#budget-box',
    methods: {
      showModal: function(d) {
        bus.$emit('open', d);
      }
    }
  });

  Vue.component('card-description', {
    props: ['card'],
    template: '#card-description'
  });

  Vue.component('budget-calculator', {
    props: ['active'],
    template: '#budget-calculator'
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
    el: "#app",
    data: {
      active: false,
      modal: false,
      current: [],
      cards: [
        {hidden: false, toggleDesc: false, title: 'Deuda pública', figure: '15,4€', description: 'El municipio tiene una deuda pendiente de 1,2M€, o 1.234€ por habitante. El año 2016 se destinan 138.000€ a pagar deuda. Imaginate que ponemos un texto que excede las tres lineas que se ven a simple vista sin necesidad de hacer scroll u otra cosa. Imaginate que ponemos un texto que excede las tres lineas que se ven a simple vista sin necesidad de hacer scroll u otra cosa. Imaginate que ponemos un texto que excede las tres lineas que se ven a simple vista sin necesidad de hacer scroll u otra cosa. '},
        {hidden: false, toggleDesc: false, title: 'Seguridad y movilidad ciudadana', figure: '70,4€', description: 'Este es el importe que se dedica cada año a devolver los créditos que se hayan pedido en el pasado (por tanto, solo refleja una parte de la deuda total del municipio, cuya devolución puede estar planteada para varios años - como cuando pides una hipoteca).'},
        {hidden: false, toggleDesc: false, title: 'Vivienda y urbanismo', figure: '145,5€', description: 'Construcción de vivienda pública, planificación urbanística, pavimentación de vias públicas y accesos a la población…'},
        {hidden: false, toggleDesc: false, title: 'Bienestar comunitario', figure: '42,7€', description: 'Este es el importe que se dedica cada año a devolver los créditos que se hayan pedido en el pasado (por tanto, solo refleja una parte de la deuda total del municipio, cuya devolución puede estar planteada para varios años - como cuando pides una hipoteca).'},
        {hidden: false, toggleDesc: false, title: 'Medio ambiente', figure: '6,3€', description: 'Este es el importe que se dedica cada año a devolver los créditos que se hayan pedido en el pasado (por tanto, solo refleja una parte de la deuda total del municipio, cuya devolución puede estar planteada para varios años - como cuando pides una hipoteca).'},
        {hidden: false, toggleDesc: false, title: 'Servicios sociales', figure: '2,98€', description: 'Este es el importe que se dedica cada año a devolver los créditos que se hayan pedido en el pasado (por tanto, solo refleja una parte de la deuda total del municipio, cuya devolución puede estar planteada para varios años - como cuando pides una hipoteca).'},
        {hidden: false, toggleDesc: false, title: 'Sanidad', figure: '0.5€', description: 'Este es el importe que se dedica cada año a devolver los créditos que se hayan pedido en el pasado (por tanto, solo refleja una parte de la deuda total del municipio, cuya devolución puede estar planteada para varios años - como cuando pides una hipoteca).'},
        {hidden: false, toggleDesc: false, title: 'Educación', figure: '75,5€', description: 'Este es el importe que se dedica cada año a devolver los créditos que se hayan pedido en el pasado (por tanto, solo refleja una parte de la deuda total del municipio, cuya devolución puede estar planteada para varios años - como cuando pides una hipoteca).'},
        {hidden: false, toggleDesc: false, title: 'Cultura', figure: '83€', description: 'Este es el importe que se dedica cada año a devolver los créditos que se hayan pedido en el pasado (por tanto, solo refleja una parte de la deuda total del municipio, cuya devolución puede estar planteada para varios años - como cuando pides una hipoteca).'},
      ]
    },
    created: function() {
      bus.$on('active', function() {
        // Not sure if this makes more sense
        //Vue.set(app, 'active', false) : Vue.set(app, 'active', true);
        Vue.set(app, 'active', true);
      });

      bus.$on('open', function(d) {
        // Set current card data
        Vue.set(app, 'current', d);

        Vue.set(app, 'modal', true);
      });

      bus.$on('close', function() {
        Vue.set(app, 'modal', false);
      });
    }
  });
});
