export class ImageLightbox {
  constructor(lightbox) {
    if (lightbox) {
      const isImg = this.isImage(lightbox);

      if (isImg || this.containsAnImg(lightbox)) {
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
        console.warn("Image-lightbox Error: there's no images in the markup");
      }
    } else {
      console.warn("Image-lightbox Error: DOM Element missing");
    }
  }

  isImage(node) {
    return node.tagName === "IMG";
  }

  containsAnImg(node) {
    return node.querySelector("img") !== null;
  }
}

// Static initialization
$(document).on("turbolinks:load", function() {
  const lightboxes = document.querySelectorAll(".js-image-lightbox");
  lightboxes.forEach(lightbox => new ImageLightbox(lightbox));
});
