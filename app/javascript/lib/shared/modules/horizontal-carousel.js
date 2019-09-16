export class HorizontalCarousel {
  constructor(carousel) {
    if (carousel) {
      this.content = carousel.firstElementChild;
      this.next = carousel.querySelector("[data-next]");
      this.prev = carousel.querySelector("[data-prev]");

      // initializations
      this.visibleItems = parseInt(carousel.dataset.visibleItems) || 1;
      this.maxValue = (this.content.children.length - this.visibleItems) * (100 / this.visibleItems);
      this.start = 0;

      // update custom CSS
      document.body.style.setProperty("--visible-items", this.visibleItems);

      // init frames
      this.setVisibility(this.next, this.start <= this.maxValue);
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

  onNextClick() {
    if (Math.abs(this.start) < this.maxValue) {
      this.start -= 100 / this.visibleItems;
      this.setTransform(this.start);
    }

    this.setVisibility(this.next, Math.abs(this.start) < this.maxValue);
    this.setVisibility(this.prev, this.start < 0);
  }

  onPrevClick() {
    if (this.start < 0) {
      this.start += 100 / this.visibleItems;
      this.setTransform(this.start);
    }

    this.setVisibility(this.prev, this.start < 0);
    this.setVisibility(this.next, Math.abs(this.start) < this.maxValue);
  }
}

// Static initialization
$(document).on("turbolinks:load", function() {
  const carousels = document.querySelectorAll(".js-horizontal-carousel");
  carousels.forEach(carousel => new HorizontalCarousel(carousel));
});
