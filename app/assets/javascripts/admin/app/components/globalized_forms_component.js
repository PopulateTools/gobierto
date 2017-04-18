this.GobiertoAdmin.GlobalizedFormsComponent = (function() {
  function GlobalizedFormsComponent() {}

  GlobalizedFormsComponent.prototype.handle = function(message) {
    $(document).on("turbolinks:load", _handleGlobalizedForm);
  };

  function _handleGlobalizedForm() {
    var $container = _findGlobalizedFormContainer();
    if(!$container.length) return;

    $container.find('[data-toggle-edit-locale]').on("click", _toggleLocaleClickHandler);
    $container.on("change", "input, select, textarea", _changeHandler);

    var currentLocale = $container.find('[data-loaded-locale]').data('loaded-locale');
    if(currentLocale === undefined)
      currentLocale = I18n.defaultLocale;
    _activateLocale(currentLocale);
    _checkCompleted($container);
  }

  function _toggleLocaleClickHandler(e){
    e.preventDefault();
    _activateLocale($(this).data('toggle-edit-locale'));
  }

  function _changeHandler(e){
    _checkCompleted(_findGlobalizedFormContainer());
  }

  function _activateLocale(currentLocale){
    var $container = _findGlobalizedFormContainer();

    $container.find('[data-toggle-edit-locale]').removeClass('selected');
    $container.find('[data-toggle-edit-locale='+currentLocale+']').addClass('selected');

    $container.find('[data-locale]').each(function(){
      $(this).data('locale') !== currentLocale ? $(this).hide() : $(this).show();
    });
  }

  function _checkCompleted($container){
    $container.find('[data-toggle-edit-locale]').each(function(){
      var locale = $(this).data('toggle-edit-locale');
      var completed = true;
      var $el = $container.find('[data-locale='+locale+']');

      $el.find("input, select, textarea").each(function(){
        if($(this).attr('id') !== undefined && $(this).val() === ""){
          completed = false;
        }
      });

      $el = $container.find('[data-toggle-edit-locale='+locale+']');
      completed ? $el.addClass('completed') : $el.removeClass('completed');
    });
  }

  function _findGlobalizedFormContainer(){
    return $("form[data-globalized-form-container] .globalized_fields");
  }

  return GlobalizedFormsComponent;
})();

this.GobiertoAdmin.globalized_forms_component = new GobiertoAdmin.GlobalizedFormsComponent;
