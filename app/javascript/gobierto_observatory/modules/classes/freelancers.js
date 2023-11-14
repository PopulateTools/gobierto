import { SimpleCard } from "lib/visualizations";
import { Card } from "./card.js";

export class FreelancersCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      `
      SELECT year, SUM(value::integer) AS value,
        CONCAT(year, '-', 1, '-', 1) AS date
        FROM afiliados_seguridad_social
          WHERE
            place_id = ${city_id} AND
            type = 'R.E.TRABAJADORES CTA. PROP. O AUTONOMOS'
        GROUP BY year
        Order BY year DESC limit 5
      `;
    this.metadata = window.populateData.endpoint.replace("data.json?sql=", "datasets/afiliados-seguridad-social/meta")
  }

  getData() {
    var data = this.handlePromise(this.url);
    var getMetaData = this.handlePromise(this.metadata);

    Promise.all([data, getMetaData]).then(([jsonData, jsonMetaData]) => {
      var opts = {
        data: jsonData.data,
        metadata: {
          "source_name": jsonMetaData.data.attributes["dataset-source"],
          "description": jsonMetaData.data.attributes.description,
          "frequency_type": jsonMetaData.data.attributes.frequency[0].name_translations[I18n.locale]
        },
        value: jsonData.data[0].value,
        cardName: "freelancers"
      }

      new SimpleCard(this.container, opts);
    });
  }
}
