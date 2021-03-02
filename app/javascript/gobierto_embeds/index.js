import "@finos/perspective";
import "@finos/perspective-viewer";
import "@finos/perspective-viewer-datagrid";
import "@finos/perspective-viewer-d3fc";
import "@finos/perspective-viewer/themes/all-themes.css";

// Look for all possible vizzs in the site
document.querySelectorAll("[data-gobierto-vizz-id]").forEach(container => {

  const data = {
    Sales: [500, 1000, 1500],
    Profit: [100.25, 200.5, 300.75]
  };

  function load() {
    const data = {
      Sales: [500, 1000, 1500],
      Profit: [100.25, 200.5, 300.75]
    };

    // The `<perspective-viewer>` HTML element exposes the viewer API
    const el = document.getElementsByTagName("perspective-viewer")[0];
    el.load(data);
  }

  // Append required elements to the DOM
  const viewer = document.createElement("perspective-viewer")
  viewer.setAttribute("columns", JSON.stringify(Object.keys(data)))
  viewer.style.width = "100%"
  container.appendChild(viewer)

  const script = document.createElement("script")
  script.innerHTML = `document.addEventListener("WebComponentsReady", ${load})`
  container.appendChild(script)

  // Run perspective
  // viewer.clear();
  // viewer.load(data);
})
