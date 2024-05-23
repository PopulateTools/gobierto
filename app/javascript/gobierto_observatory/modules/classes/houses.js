import { ComparisonCard } from '../../../lib/visualizations';
import { Card } from './card.js';

export class HousesCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.query = `
      SELECT SUM(total_viviendas_familiares ::integer) AS value
      FROM viviendas
      WHERE
        place_id = ${city_id} AND
        year = (SELECT max(year) FROM viviendas )
      UNION
      SELECT SUM(total_viviendas_principales ::integer) AS value
      FROM viviendas
      WHERE
        place_id = ${city_id} AND
        year = (SELECT max(year) FROM viviendas )
      `;

    this.metadata = this.getMetadataEndpoint("viviendas");
  }

  getData([jsonData, jsonMetadata]) {
    var [familyHouses, mainHouses] = jsonData.data;

    var opts = {
      metadata: this.getMetadataFields(jsonMetadata),
      cardName: "houses"
    };

    new ComparisonCard(
      this.container,
      familyHouses.value,
      mainHouses.value,
      opts
    );
  }
}
