this.GobiertoAdmin.GlobalizedFormsComponent = (function() {
  function GlobalizedFormsComponent() {}

  GlobalizedFormsComponent.prototype.handle = function(message) {
    $(document).on("turbolinks:load", _handleGlobalizedForm);
  };

  function _handleGlobalizedForm() {
    var $globalizedForm = _findGlobalizedForm();
    if(!$globalizedForm.length) return;

    $globalizedForm.find('[data-toggle-edit-locale]').on("click", _toggleLocaleClickHandler);
    $globalizedForm.on("change", "input, select, textarea", _changeHandler);

    var currentLocale = $globalizedForm.find('[data-loaded-locale]').data('loaded-locale');
    if(currentLocale === undefined)
      currentLocale = I18n.defaultLocale;
    _activateLocale(currentLocale);
    _checkCompleted($globalizedForm);
  }

  function _toggleLocaleClickHandler(e){
    e.preventDefault();
    _activateLocale($(this).data('toggle-edit-locale'));
  }

  function _changeHandler(e){
    _checkCompleted(_findGlobalizedForm());
  }

  function _activateLocale(currentLocale){
    var $globalizedForm = _findGlobalizedForm();

    $globalizedForm.find('[data-toggle-edit-locale]').removeClass('selected');
    $globalizedForm.find('[data-toggle-edit-locale='+currentLocale+']').addClass('selected');

    $globalizedForm.find('[data-locale]').each(function(){
      $(this).data('locale') !== currentLocale ? $(this).hide() : $(this).show();
    });
  }

  function _checkCompleted($globalizedForm){
    $globalizedForm.find('[data-toggle-edit-locale]').each(function(){
      var locale = $(this).data('toggle-edit-locale');
      var completed = true;
      var $el = $globalizedForm.find('[data-locale='+locale+']');

      $el.find("input, select, textarea").each(function(){
        if($(this).attr('id') !== undefined && $(this).val() === ""){
          completed = false;
        }
      });

      $el = $globalizedForm.find('[data-toggle-edit-locale='+locale+']');
      completed ? $el.addClass('completed') : $el.removeClass('completed');
    });
  }

  function _findGlobalizedForm(){
    return $("form[data-globalized-form-container]");
  }

  return GlobalizedFormsComponent;
})();

this.GobiertoAdmin.globalized_forms_component = new GobiertoAdmin.GlobalizedFormsComponent;
