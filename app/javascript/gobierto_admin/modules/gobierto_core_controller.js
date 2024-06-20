import CodeMirror from 'codemirror'

window.GobiertoAdmin.GobiertoCoreController = (function() {
  function GobiertoCoreController() {}

  GobiertoCoreController.prototype.index = function() {
    _loadCodeMirror();
  };

  function _loadCodeMirror() {
    var te_html = document.getElementById("code");

    window.editor_html = CodeMirror.fromTextArea(te_html, {
      mode: "text/html",
      lineNumbers: true,
      lineWrapping: true,
      viewportMargin: Infinity,
      extraKeys: { "Ctrl-Q": function(cm){ cm.foldCode(cm.getCursor()); } },
      foldGutter: true,
      gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"]
    });
  }

  return GobiertoCoreController;
})();

window.GobiertoAdmin.gobierto_core_controller = new GobiertoAdmin.GobiertoCoreController;
