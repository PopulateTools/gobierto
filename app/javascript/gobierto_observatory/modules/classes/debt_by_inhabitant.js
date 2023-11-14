import { BarsCard } from "lib/visualizations";
import { Card } from "./card.js";

export class DebtByInhabitantCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      `
      SELECT value, CONCAT(year, '-', 1, '-', 1) as date
      FROM deuda_municipal
      WHERE
        place_id = ${city_id}
      `;
    this.bcnUrl =
      window.populateData.endpoint +
      `
      SELECT value
      FROM deuda_municipal
      WHERE
        place_id = 08019
      `;

    this.vlcUrl =
      window.populateData.endpoint +
      `
      SELECT value
      FROM deuda_municipal
      WHERE
        place_id = 46250
      `;

    this.figureCityURL =
      window.populateData.endpoint +
      `
      SELECT SUM(total::integer) AS value
        FROM poblacion_edad_sexo
        WHERE
          place_id = ${city_id} AND
          year = (SELECT max(year) FROM poblacion_edad_sexo)
      `;

    this.figureBcnURL =
      window.populateData.endpoint +
      `
      SELECT SUM(total::integer) AS value
        FROM poblacion_edad_sexo
        WHERE
          place_id = 08019 AND
          year = (SELECT max(year) FROM poblacion_edad_sexo)
      `;
    this.figureVlcURL =
      window.populateData.endpoint +
      `
      SELECT SUM(total::integer) AS value
        FROM poblacion_edad_sexo
        WHERE
          place_id = 46250 AND
          year = (SELECT max(year) FROM poblacion_edad_sexo)
      `;

    this.metadata = window.populateData.endpoint.replace(
      "data.json?sql=",
      "datasets/deuda-municipal/meta"
    );
  }

  getData() {
    var data = this.handlePromise(this.url);
    var bcn = this.handlePromise(this.bcnUrl);
    var vlc = this.handlePromise(this.vlcUrl);

    var dataPopulation = this.handlePromise(this.figureCityURL);
    var bcnPopulation = this.handlePromise(this.figureBcnURL);
    var vlcPopulation = this.handlePromise(this.figureVlcURL);

    var getMetaData = this.handlePromise(this.metadata);

    Promise.all([
      data,
      bcn,
      vlc,
      dataPopulation,
      bcnPopulation,
      vlcPopulation,
      getMetaData
    ]).then(
      ([
        json,
        bcn,
        vlc,
        dataPopulation,
        bcnPopulation,
        vlcPopulation,
        jsonMetaData
      ]) => {
        json.data.forEach(function(d) {
          d.figure = d.value / dataPopulation.data[0].value;
          d.key = window.populateData.municipalityName;
        });

        bcn.data.forEach(function(d) {
          d.figure = d.value / bcnPopulation.data[0].value;
          d.key = "Barcelona";
        });

        vlc.data.forEach(function(d) {
          d.figure = d.value / vlcPopulation.data[0].value;
          d.key = "Valencia";
        });

        this.data = [json.data[0], bcn.data[0], vlc.data[0]];

        new BarsCard(this.container, json.data, {
          metadata: {
            "source_name": jsonMetaData.data.attributes["dataset-source"],
            "description": jsonMetaData.data.attributes.description,
            "frequency_type": jsonMetaData.data.attributes.frequency[0].name_translations[I18n.locale]
          },
          value: this.data,
          cardName: "debt_by_inhabitant"
        });
      }
    );
  }
}
