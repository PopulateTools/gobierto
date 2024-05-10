import { checkAndReportAccessibility } from '../lib/shared';
import '../../assets/stylesheets/observatory.scss';
import './modules/application.js';

document.addEventListener('DOMContentLoaded', () => {
  const demographyMapAppNode = document.getElementById("gobierto-observatory-demography-map-app");

  if (process.env.NODE_ENV === 'development') {
    checkAndReportAccessibility()
  }

  if (demographyMapAppNode !== null) {
    // load only the module in the "/observatorio/mapa" path
    import('./modules/demography_map_controller.js').then(({ DemographyMapController }) => {
      new DemographyMapController({
        selector: demographyMapAppNode.id,
        sectionsEndpoint: demographyMapAppNode.dataset.endpointSections,
        studiesEndpoint: demographyMapAppNode.dataset.endpointStudies,
        originEndpoint: demographyMapAppNode.dataset.endpointOrigin,
        mapLat: demographyMapAppNode.dataset.mapLat,
        mapLon: demographyMapAppNode.dataset.mapLon,
        ineCode: demographyMapAppNode.dataset.ineCode
      });
    })

  }
});
