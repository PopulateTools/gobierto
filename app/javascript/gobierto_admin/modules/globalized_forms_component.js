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
    if(!containers.length) return;

    containers.find('[data-toggle-edit-locale]').on("click", _toggleLocaleClickHandler);
    containers.on("change", "input, select, textarea", _changeHandler);

    var currentLocale = containers.find('[data-loaded-locale]').data('loaded-locale');

    if(currentLocale === undefined)
      currentLocale = I18n.defaultLocale;
    containers.each(function(index, container) {
      _activateLocale(currentLocale, container);
      _checkCompleted(container);
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
        if($(this).attr('id') !== undefined && $(this).val() === ""){
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

  return GlobalizedFormsComponent;
})();

window.GobiertoAdmin.globalized_forms_component = new GobiertoAdmin.GlobalizedFormsComponent;
