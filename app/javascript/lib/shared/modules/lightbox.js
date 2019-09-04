$(document).on("turbolinks:load", function() {

  const lightboxes = document.querySelectorAll(".js-lightbox")

  const isImg = node => node.tagName === "IMG"
  const containsAnImg = node => node.querySelector("img") !== null

  lightboxes.forEach(lightbox => {

    if (isImg(lightbox) || containsAnImg(lightbox)) {
      if (isImg(lightbox)) {
        lightbox.setAttribute("data-mfp-src", lightbox.src)
      }

      $(lightbox).magnificPopup({
        type: 'image',
        closeOnContentClick: true,
        image: {
          verticalFit: true
        }
      });
    } else {
      console.error(lightbox, "isn't an image nor contains one");
    }

  })

});
