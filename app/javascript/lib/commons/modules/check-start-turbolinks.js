import Turbolinks from 'turbolinks'

document.addEventListener("DOMContentLoaded", () => {
  const disableTurbolinks = document.querySelector("body[data-turbolinks='false']")

  // If we don't found at body level this tag, we enable Turbolinks by default
  if (!disableTurbolinks) {
    Turbolinks.start()
  }
})
