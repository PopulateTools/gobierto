import './modules/application.js'
import { DemographyMapController } from "./modules/demography_map_controller.js";

document.addEventListener('DOMContentLoaded', () => {
  const demographyMapAppNode = document.getElementById("gobierto-observatory-demography-map-app");
  if (demographyMapAppNode !== null) {
    new DemographyMapController({
      selector: demographyMapAppNode.id,
      sectionsEndpoint: demographyMapAppNode.dataset.endpointSections,
      studiesEndpoint: demographyMapAppNode.dataset.endpointStudies,
      originEndpoint: demographyMapAppNode.dataset.endpointOrigin,
      mapLat: demographyMapAppNode.dataset.mapLat,
      mapLon: demographyMapAppNode.dataset.mapLon,
      ineCode: demographyMapAppNode.dataset.ineCode
    });
  }
});
