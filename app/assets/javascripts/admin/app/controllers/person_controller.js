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
            console.log('Popup is opened');

            if ($loaded_image.files && $loaded_image.files[0]) {
                var reader = new FileReader();
                reader.onload = function () {
                  var dataURL = reader.result;
                  var output = document.getElementById('image');
                  output.src = dataURL;

                  var cropper = new Cropper(output, {
                      aspectRatio: 1 / 1,
                      crop: function(e) {
                          console.log('"crop" event has fired.');
                      }
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
        var file = document.getElementById('person_avatar_image');
        //file.val = output.cropper.getCroppedCanvas().toDataURL("image/png");
        image = new Image();
        image = imgurl;
        file.val = "";
        file.val = image;


        $crop_x.val(output.cropper.getData()["x"]);
        $crop_y.val(output.cropper.getData()["y"]);
        $crop_w.val(output.cropper.getData()["width"]);
        $crop_h.val(output.cropper.getData()["height"]);
        //image.src = imgurl;
        // Get a string base 64 data url
        //var croppedImageDataURL = output.cropper('getCroppedCanvas').toDataURL("image/png");
        //$result.append( $('<img>').attr('src', croppedImageDataURL) );
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
