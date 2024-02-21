import Cropper from 'cropperjs'

window.GobiertoAdmin.PersonController = (function() {
  function PersonController() {}

  PersonController.prototype.form = function() {
    _selectByDefault();
    _handlePositionSelector();
    _cropImage();
  };

  function _cropImage() {
    var uid = "person_avatar_image";

    $(`#${ uid }`).change(function () {
      var $loaded_image = this;

      validatesImageDimensionsToCrop($loaded_image);
    });

    $('#btnCrop').click(function() {
      var output = document.getElementById("image");

      $.magnificPopup.close();

      $('#saved_image').hide();

      output.cropper.getCroppedCanvas().toBlob((blob) => {
        // https://pqina.nl/blog/set-value-to-file-input/
        const file = new File([blob], document.getElementById(uid).files[0].name, { type: blob.type })
        const dt = new DataTransfer()
        dt.items.add(file)

        document.getElementById(uid).files = dt.files
      });
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
    if (!$('#person_party_government').is(':checked') && !$('#person_party_opposition').is(':checked'))
      $('#person_party_government').prop('checked', true);
  }

  function openCropModal(loaded_image) {
    $.magnificPopup.open({
      items: {
        src: '#crop-popup'
      },
      type: 'inline',
      callbacks: {
        open: function() {
          if (loaded_image.files && loaded_image.files[0]) {
            var reader = new FileReader();
            reader.onload = function () {
              var dataURL = reader.result;

              var output = document.getElementById('image');

              // Hack: Clear cropper
              if (output.classList.contains("cropper-hidden")) {
                output.src= "";
                output.cropper.destroy();
              }

              output.src = dataURL;

              new Cropper(output, {
                aspectRatio: 1 / 1,
                minCropBoxWidth: 500,
                minCropBoxHeight: 500
              });
            }
            reader.readAsDataURL(loaded_image.files[0]);
          }
        }
      }
    });
  }

  function validatesImageDimensionsToCrop(loaded_image) {
    var reader = new FileReader();

    reader.readAsDataURL(loaded_image.files[0]);
    reader.onload = function (e) {
      var image = new Image();

      image.src = e.target.result;

      image.onload = function () {
        var height = this.height;
        var width = this.width;
        if ((height > 500 || width > 500)) {
          openCropModal(loaded_image);
        } else {
          $('#saved_image').hide();
        }
      };
    };
  }

  return PersonController;
})();

window.GobiertoAdmin.person_controller = new GobiertoAdmin.PersonController;
