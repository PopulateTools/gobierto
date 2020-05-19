import './modules/application.js'
import { DemographyMapController } from "./modules/demography_map_controller.js";

document.addEventListener('DOMContentLoaded', () => {
  const demographyMapAppNode = document.getElementById("gobierto-observatory-demography-map-app");
  if(demographyMapAppNode !== null) {
    new DemographyMapController({
      selector: demographyMapAppNode.id,
      siteName: demographyMapAppNode.dataset.siteName,
      logoUrl: demographyMapAppNode.dataset.logoUrl,
      homeUrl: demographyMapAppNode.dataset.homeUrl,
      studiesEndpoint: demographyMapAppNode.dataset.endpointStudies,
      originEndpoint: demographyMapAppNode.dataset.endpointOrigin
    });
  }
});
