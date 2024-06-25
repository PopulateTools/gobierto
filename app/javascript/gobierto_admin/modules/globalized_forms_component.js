window.GobiertoAdmin.GlobalizedFormsComponent = (function() {
  function GlobalizedFormsComponent() {}

  GlobalizedFormsComponent.prototype.handle = function() {
    $(document).on("turbolinks:load", _handleGlobalizedForm);
  };

  GlobalizedFormsComponent.prototype.handleGlobalizedForm = function() {
    _handleGlobalizedForm();
  };

  function _handleGlobalizedForm() {
    var containers = _findGlobalizedFormContainers();
    if (!containers.length) return;

    containers.find('[data-toggle-edit-locale]').on("click", _toggleLocaleClickHandler);
    containers.on("change", "input, select, textarea", _changeHandler);

    var currentLocale = containers.find('[data-loaded-locale]').data('loaded-locale');

    if (currentLocale === undefined)
      currentLocale = I18n.defaultLocale;
    containers.each(function(index, container) {
      _activateLocale(currentLocale, container);
      _checkCompleted(container);

      // Turn locate toggle component into a floating element
      // It must do after other locale fields have been hidden
      _toggleFloatingLocaleComponent(container)
    });
  }

  function _toggleLocaleClickHandler(e){
    e.preventDefault();

    var container = $(e.target).closest(".globalized_fields");

    // When globalized form is in a popup, previous selector doesn't work
    if (container === null) {
      container = $(e.target).parents().filter("div .globalized_fields")
    }

    _activateLocale($(this).data('toggle-edit-locale'), container);
  }

  function _changeHandler(){
    _checkCompleted(_findGlobalizedFormContainers());
  }

  function _activateLocale(currentLocale, container){
    $(container).find('[data-toggle-edit-locale]').removeClass('selected');
    $(container).find('[data-toggle-edit-locale=' + currentLocale + ']').filter('a').addClass('selected');

    $(container).find('[data-locale]').each(function(){
      $(this).data('locale') !== currentLocale ? $(this).hide() : $(this).show();
    });
  }

  function _checkCompleted(container){
    $(container).find('[data-toggle-edit-locale]').each(function(){
      var locale = $(this).data('toggle-edit-locale');
      var completed = true;
      var $el = $(container).find('[data-locale='+locale+']');

      $el.find("input, select, textarea").each(function(){
        if ($(this).attr('id') !== undefined && $(this).val() === ""){
          completed = false;
        }
      });

      $el = $(container).find('[data-toggle-edit-locale='+locale+']');
      completed ? $el.addClass('completed') : $el.removeClass('completed');
    });
  }

  function _findGlobalizedFormContainers(){
    return $("form[data-globalized-form-container] .globalized_fields");
  }

  function _toggleFloatingLocaleComponent(container) {
    const $container = $(container)
    const $localizedFields = $container.find("[data-locale]")
    const amountOfLocales = Object.keys(I18n.translations).length

    // Ignore if the number of fields to be translated is lower than the total of available locales
    // We want to make a floating locale if there are a few, at least
    if ($localizedFields.length > amountOfLocales) {
      const containerHeight = $container.height()
      const headerHeight = $("header").height()
      const containerOffsetTop = $container.offset().top - headerHeight
      // In order to hide before scroll reaches container bottom
      const decoratorLastItem = $container.find("> *:last-of-type").height() * .4
      const containerOffsetBottom = containerOffsetTop + containerHeight - decoratorLastItem

      $(window).on("scroll resize", function () {
        const scroll = $(this).scrollTop()

        if ((scroll > containerOffsetTop) && (scroll < containerOffsetBottom)) {
          $container.addClass("is-floating")

          const $tool = $container.find("> *:first-child")
          // JQuery does not accept shorthand properties
          const horizontalPx = parseInt($tool.css("padding-left")) + parseInt($tool.css("padding-right")) + parseInt($tool.css("border-left-width")) + parseInt($tool.css("border-right-width"))

          $tool.width($container.width() - horizontalPx)
        } else {
          $container.removeClass("is-floating")
        }
      })
    }
  }

  return GlobalizedFormsComponent;
})();

window.GobiertoAdmin.globalized_forms_component = new GobiertoAdmin.GlobalizedFormsComponent;
