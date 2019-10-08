$(document).on("turbolinks:load", function() {
  const tabs = document.querySelectorAll("[role^=tabs]");
  const activeClass = "is-active";

  const getSeed = str => {
    const pattern = new RegExp(/^tabs-(.*)/);
    const match = pattern.exec(str) || [];
    return match.length > 1 ? match[1] : undefined;
  };

  const deactivate = elems => {
    for (let i = 0; i < elems.length; i++) {
      elems[i].classList.remove(activeClass);
    }
  };

  const activate = elems => {
    for (let i = 0; i < elems.length; i++) {
      elems[i].classList.add(activeClass);
    }
  };

  tabs.forEach(tab => {
    const seed = getSeed(tab.getAttribute("role"));

    if (seed) {
      const tabscontent = document.querySelector(`[role=tabscontent-${seed}]`);
      const tabcontent = tabscontent.querySelectorAll("[role=tabcontent]");
      const tablinks = tab.querySelectorAll("[role=tablink]");

      for (let i = 0; i < tablinks.length; i++) {
        if (tablinks[i].classList.contains(activeClass) || tabcontent[i].classList.contains(activeClass)) {
          activate([tablinks[i], tabcontent[i]]);
        }

        tablinks[i].addEventListener("click", function(event) {
          const elem = event.currentTarget;

          if (!elem.classList.contains(activeClass)) {
            deactivate([...tablinks, ...tabcontent]);

            const index = [...tablinks].indexOf(elem);
            activate([elem, tabcontent[index]]);
          }
        });
      }
    }
  });
});
