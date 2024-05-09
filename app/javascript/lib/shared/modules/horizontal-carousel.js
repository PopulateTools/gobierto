import { ImageLightbox } from './image-lightbox';

export class HorizontalCarousel {
  constructor(carousel) {
    if (carousel) {
      this.content = carousel.firstElementChild;
      this.next = carousel.querySelector("[data-next]");
      this.prev = carousel.querySelector("[data-prev]");

      // initializations
      const { visibleItems, thumbnails } = carousel.dataset
      this.start = 0;
      this.thumbnails = thumbnails;

      if (this.thumbnails && this.content.children.length > 1) {
        carousel.parentNode.insertBefore(document.createElement("div"), carousel.parentNode.firstElementChild)
        this.setActiveThumbnail(this.content.firstElementChild)

        // event handling for thumbnails
        this.content.children.forEach(child => {
          child.addEventListener("click", this.onThumbnailClick.bind(this))
          child.classList.add("is-thumbnail")
        })

        const avg = [...this.content.children].reduce((acc, b) => acc + b.getBoundingClientRect().width, 0) / this.content.children.length
        // const [{ width: totalWidth }, { width }] = [, this.content.children[1].getBoundingClientRect()]
        this.visibleItems = this.content.getBoundingClientRect().width / avg
      } else {
        this.visibleItems = parseInt(visibleItems) || 1;
        this.content.children.forEach(child => (child.style.flex = `0 0 calc(100% / ${this.visibleItems})`));
      }

      this.maxValue = (this.content.children.length - this.visibleItems) * (100 / this.visibleItems);

      // init frames
      this.setVisibility(this.next, this.start < this.maxValue);
      this.setVisibility(this.prev, this.start !== 0);

      // event handling
      this.next.addEventListener("click", this.onNextClick.bind(this));
      this.prev.addEventListener("click", this.onPrevClick.bind(this));
    } else {
      console.warn("Horizontal Carousel Error: DOM Element missing");
    }
  }

  setTransform() {
    this.content.style.transform = `translateX(${this.start}%)`;
  }

  setVisibility(element, visible = true) {
    element.style.visibility = visible ? "visible" : "hidden";
  }

  setActiveThumbnail(node) {
    const carousel = this.content.parentNode
    const copy = node.cloneNode(true)
    copy.classList.remove("is-thumbnail")
    copy.classList.add("is-active")
    copy.style = "position:relative;"
    carousel.parentNode.replaceChild(copy, carousel.parentNode.firstElementChild)

    new ImageLightbox(copy)

    copy.querySelector("img").addEventListener("load", this.onImageLoad.bind(this))
  }

  onNextClick() {
    if (Math.abs(this.start) < this.maxValue) {
      this.start -= 100 / this.visibleItems;
      this.start = Math.ceil(Math.abs(this.start)) > this.maxValue ? -1 * this.maxValue : this.start
      this.setTransform(this.start);
    }

    this.setVisibility(this.next, Math.abs(this.start) < this.maxValue);
    this.setVisibility(this.prev, this.start < 0);
  }

  onPrevClick() {
    if (this.start < 0) {
      this.start += 100 / this.visibleItems;
      this.start = Math.ceil(this.start) > 0 ? 0 : this.start
      this.setTransform(this.start);
    }

    this.setVisibility(this.prev, this.start < 0);
    this.setVisibility(this.next, Math.abs(this.start) < this.maxValue);
  }

  onThumbnailClick({ currentTarget }) {
    this.setActiveThumbnail(currentTarget)
  }

  onImageLoad({ target }) {
    const { naturalHeight, naturalWidth } = target;
    if (naturalHeight > naturalWidth) {
      target.classList.add("is-portrait");
    }
  }

  destroy() {
    this.next.removeEventListener("click", this.onNextClick.bind(this));
    this.prev.removeEventListener("click", this.onPrevClick.bind(this));

    if (this.thumbnails && this.content.children.length > 1) {
      this.content.children.forEach(child => child.removeEventListener("click", this.onThumbnailClick.bind(this)))
    }
  }
}

// Static initialization
$(document).on("turbolinks:load", function() {
  const carousels = document.querySelectorAll(".js-horizontal-carousel");
  carousels.forEach(carousel => new HorizontalCarousel(carousel));
});
