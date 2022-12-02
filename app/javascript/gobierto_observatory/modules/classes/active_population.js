import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";

export class ActivePopulationCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.activePopUrl = window.populateData.endpoint + `
    SELECT SUM(total::integer) AS value
    FROM poblacion_edad_sexo
    WHERE
      place_id = ${city_id} AND
      year = (SELECT max(year) FROM poblacion_edad_sexo ) AND
      age >= 16 AND
      sex = 'Total'
    `;
    this.popUrl = window.populateData.endpoint + `
    SELECT SUM(total::integer) AS value
    FROM poblacion_edad_sexo
    WHERE
      place_id = ${city_id} AND
      year = (SELECT max(year) FROM poblacion_edad_sexo ) AND
      sex = 'Total'
    `;
  }

  getData() {
    var active = this.handlePromise(this.activePopUrl);
    var pop = this.handlePromise(this.popUrl);

    Promise.all([active, pop]).then(([jsonActive, jsonPop]) => {
      var value = jsonActive.data[0].value;
      var rate = (value / jsonPop.data[0].value) * 100;

      new ComparisonCard(this.container, jsonActive, rate, value, "active_pop");
    });
  }
}
