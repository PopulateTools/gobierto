function dropdown({ currentTarget }) {
  /*
    HOW TO USE JS-DROPDOWN

    <div>
      <button class="js-dropdown" data-dropdown="NAME"></button>
      <div class="hidden" data-dropdown="NAME"></div>
    </div>

    - Notice that NAME property must be equal both trigger and contents
    - Add 'js-dropdown' class to the trigger (button tag or whatever) and 'hidden' to the contents
  */

  const { dropdown } = currentTarget.dataset;
  const content = document.querySelector(`[data-dropdown="${dropdown}"]:not(.js-dropdown)`)

  content.classList.toggle("hidden");
  content.parentElement.style.position = "relative";
}

export default function () {
  document.querySelectorAll(".js-dropdown").forEach(element => element.addEventListener("click", dropdown))
}
