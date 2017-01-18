document.addEventListener("trix-initialize", function(event) {
  var trix = event.target;
  var attachButton, toolbarButton;

  attachButton = document.createElement("button");
  attachButton.setAttribute("type", "button");
  attachButton.setAttribute("class", "icon attach");
  attachButton.setAttribute("data-trix-action", "x-attach");
  attachButton.setAttribute("title", "Attach a file");
  attachButton.setAttribute("tabindex", "-1");
  attachButton.innerText = "Attach a file";

  toolbarButton = trix.toolbarElement
    .querySelector(".button_group.block_tools")
    .appendChild(attachButton);

  toolbarButton.addEventListener("click", function() {
    var fileInput = document.createElement("input");

    fileInput.setAttribute("type", "file");
    fileInput.setAttribute("multiple", "");

    fileInput.addEventListener("change", function() {
      var file, _i, _len, _ref, _results;

      _ref = this.files;
      _results = [];

      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        file = _ref[_i];
        _results.push(trix.editor.insertFile(file));
      }

      return _results;
    });

    fileInput.click();
  });
});
