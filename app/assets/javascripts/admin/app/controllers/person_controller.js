this.GobiertoAdmin.PersonController = (function() {
  function PersonController() {}

  PersonController.prototype.form = function() {
    _selectByDefault();
    _handlePositionSelector();
    _cropImage();
  };

  function _cropImage() {
    $("#person_avatar_image").change(function () {
      var $loaded_image = this;

      $.magnificPopup.open({
        items: {
          src: '#test-popup',
          type: 'inline'
        },
        callbacks: {
          open: function() {
            if ($loaded_image.files && $loaded_image.files[0]) {
                var reader = new FileReader();
                reader.onload = function () {
                  var dataURL = reader.result;
                  var output = document.getElementById('image');
                  output.src = dataURL;

                  var cropper = new Cropper(output, {
                      aspectRatio: 1 / 1,
                      minCropBoxWidth: 500,
                      minCropBoxHeight: 500
                  });
                }
                reader.readAsDataURL($loaded_image.files[0]);
            }
          }
        }
      });
    });

    $('#btnCrop').click(function() {
      var $crop_x = $("input#logo_crop_x"),
          $crop_y = $("input#logo_crop_y"),
          $crop_w = $("input#logo_crop_w"),
          $crop_h = $("input#logo_crop_h");
        var output = document.getElementById('image');
        var imgurl =  output.cropper.getCroppedCanvas().toDataURL("image/png");

        $.magnificPopup.close();

        $('#saved_image').hide();

        $crop_x.val(output.cropper.getData()["x"]);
        $crop_y.val(output.cropper.getData()["y"]);
        $crop_w.val(output.cropper.getData()["width"]);
        $crop_h.val(output.cropper.getData()["height"]);
    });

  }

  function _handlePositionSelector() {
    $('#person_category_politician').on('change', function(){
      var $target = $('[data-target]');
      $target.show();
    });
    $('#person_category_executive').on('change', function(){
      var $target = $('[data-target]');
      $target.hide();
    });
  }

  function _selectByDefault(){
    if(!$('#person_party_government').is(':checked') && !$('#person_party_opposition').is(':checked'))
      $('#person_party_government').prop('checked', true);
  }

  return PersonController;
})();

this.GobiertoAdmin.person_controller = new GobiertoAdmin.PersonController;
