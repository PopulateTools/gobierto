//https://github.com/Leaflet/Leaflet.markercluster/issues/874
import * as L from 'leaflet';
import 'leaflet/dist/leaflet.css';

function buildMap() {
  let geojson

  function style(feature) {
    return {
      fillColor: 'var(--color-base)',
      weight: 1,
      opacity: 1,
      color: 'rgba(var(--color-base-string), 0.5)',
      fillOpacity: 0.3
    };
  }

  function highlightFeature(e) {
    const {
      target: layer
    } = e

    layer.setStyle({
      weight: 1,
      color: 'rgba(var(--color-base-string), 0.3)',
      fillOpacity: 0.7
    });

    if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge) {
      layer.bringToFront();
    }
  }

  function resetHighlight(e) {
    const {
      target
    } = e
    geojson.resetStyle(target);
  }

  function onEachFeature(feature, layer) {
    layer.on({
      mouseover: highlightFeature,
      mouseout: resetHighlight
    });
  }

  function onClick(e) {
    alert(this.getLatLng());
  }

  function map() {
    const mapboxAccessToken = "pk.eyJ1IjoiZmVyYmxhcGUiLCJhIjoiY2pqMzNnZjcxMTY1NjNyczI2ZXQ0dm1rYiJ9.yUynmgYKzaH4ALljowiFHw";
    const map = L.map('map').setView([40.309,-3.680], 13.45);
    L.tileLayer('https://api.mapbox.com/styles/v1/{username}/{style_id}/tiles/{z}/{x}/{y}?access_token=' + mapboxAccessToken, {
      username: "gobierto",
      style_id: "ck18y48jg11ip1cqeu3b9wpar",
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      tileSize: 512,
      minZoom: 9,
      maxZoom: 16,
      zoomOffset: -1
    }).addTo(map);

    let request = new XMLHttpRequest();
    request.open('GET', "https://demo-datos.gobify.net/api/v1/data/data?sql=select%20geometry%20from%20secciones_censales%20where%20cumun=28065", true);

    request.onload = function() {
      const {
        status,
        responseText
      } = request

      if (status >= 200 && status < 400) {
        let data = JSON.parse(responseText);
        const {
          data: responseData
        } = data

        const sections = {
          "type": "FeatureCollection",
          "features": responseData.map(i => JSON.parse(i.geometry))
        }

        console.log("sections", sections);

        geojson = L.geoJson(sections, {
          style: style,
          onEachFeature: onEachFeature
        }).addTo(map).on('mouseover', onClick);
      } else {
        console.log("ERROR! in the request")
      }
    };

    request.onerror = function() {
      // There was a connection error of some sort
    };

    request.send();
  }

  document.addEventListener("DOMContentLoaded", map);
}

export default buildMap
