export const readMore = el => {
  el.firstElementChild.querySelector("[data-toggle]").addEventListener("click", () => el.classList.add("is-active"));
  el.lastElementChild.querySelector("[data-toggle]").addEventListener("click", () => el.classList.remove("is-active"));
};

// Static initialization
$(document).on("turbolinks:load", function() {
  const elements = document.querySelectorAll(".js-read-more");
  elements.forEach(el => readMore(el));
});
