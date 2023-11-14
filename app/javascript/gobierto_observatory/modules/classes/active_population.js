import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";

export class ActivePopulationCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.activePopUrl = window.populateData.endpoint + `
    SELECT SUM(total::integer) AS value, CONCAT(year, '-', 1, '-', 1) AS date
    FROM poblacion_edad_sexo
    WHERE
      place_id = ${city_id} AND
      year = (SELECT max(year) FROM poblacion_edad_sexo ) AND
      age >= 16 AND
      sex = 'Total'
    GROUP BY year
    `;
    this.popUrl = window.populateData.endpoint + `
    SELECT SUM(total::integer) AS value
    FROM poblacion_edad_sexo
    WHERE
      place_id = ${city_id} AND
      year = (SELECT max(year) FROM poblacion_edad_sexo ) AND
      sex = 'Total'
    `;
    this.metadata = window.populateData.endpoint.replace("data.json?sql=", "datasets/poblacion-edad-sexo/meta")
  }

  getData() {
    var active = this.handlePromise(this.activePopUrl);
    var pop = this.handlePromise(this.popUrl);
    var getMetaData = this.handlePromise(this.metadata);

    Promise.all([active, pop, getMetaData]).then(([jsonActive, jsonPop, jsonMetaData]) => {
      var value = jsonActive.data[0].value;
      var rate = (value / jsonPop.data[0].value) * 100;

      var opts = {
        metadata: {
          "source_name": jsonMetaData.data.attributes["dataset-source"],
          "description": jsonMetaData.data.attributes.description,
          "frequency_type": jsonMetaData.data.attributes.frequency[0].name_translations[I18n.locale]
        },
        value_1: rate,
        value_2: value,
        cardName: "active_pop"
      }

      new ComparisonCard(this.container, jsonActive.data, opts);
    });
  }
}
