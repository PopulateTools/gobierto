$(document).on("turbolinks:load", function() {
  const lightboxes = document.querySelectorAll(".js-image-lightbox");

  const isImage = node => node.tagName === "IMG";
  const containsAnImg = node => node.querySelector("img") !== null;
  
  lightboxes.forEach(lightbox => {
    const isImg = isImage(lightbox)

    if (isImg || containsAnImg(lightbox)) {
      const options = {
        type: "image",
        closeOnContentClick: true,
        closeBtnInside: false,
        image: {
          verticalFit: true
        },
        items: {
          src: isImg ? lightbox.src : lightbox.querySelector("img").src
        }
      };

      $(lightbox).magnificPopup(options);
    } else {
      console.warn("Image-lightbox Error: there's no images in the markup")
    }

  });
});
