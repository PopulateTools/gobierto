$(document).on("turbolinks:load", function() {

  const carousel = document.querySelector(".js-horizontal-carousel")
  const content = carousel.firstElementChild
  
  const next = carousel.querySelector("[data-next]")
  const prev = carousel.querySelector("[data-prev]")
  
  // initializations
  const visibleItems = parseInt(carousel.dataset.visibleItems) || 1
  const maxValue = (content.children.length - visibleItems) * (100 / visibleItems)
  let start = 0
  
  // update custom CSS'
  document.body.style.setProperty("--visible-items", visibleItems)
  
  // update frame position
  const setTransform = p => (content.style.transform = `translateX(${start}%)`)

  // update arrows
  const setVisibility = (element, visible = true) => (element.style.visibility = visible ? 'visible' : 'hidden')

  setVisibility(next, (start <= maxValue))
  setVisibility(prev, (start !== 0))
  
  next.addEventListener("click", () => {
    if (Math.abs(start) < maxValue) {
      start -= 100 / visibleItems
      setTransform(start)
    }

    setVisibility(next, Math.abs(start) < maxValue)
    setVisibility(prev, start < 0)
  })
  
  prev.addEventListener("click", () => {
    if (start < 0) {
      start += 100 / visibleItems
      setTransform(start)
    }

    setVisibility(prev, start < 0)
    setVisibility(next, Math.abs(start) < maxValue)
  })
  
});
