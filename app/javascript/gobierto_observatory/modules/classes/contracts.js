import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";

export class ContractsCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.query = `
      WITH maxyear AS
        (SELECT year,
                month
        FROM contratos_personas
        WHERE place_id = ${city_id}
        ORDER BY year DESC, month DESC
        LIMIT 1)
      SELECT type,
            SUM(value::integer) AS value
      FROM contratos_personas
      WHERE place_id = ${city_id}
        AND type IN ('temporary',
                    'undefined')
        AND year =
          (SELECT year
          FROM maxyear)
        AND month =
          (SELECT month
          FROM maxyear)
      GROUP BY type
      ORDER BY type
      `;

    this.metadata = this.getMetadataEndpoint("afiliados-seguridad-social");
  }

  getData([jsonData, jsonMetadata]) {
    var [temporaryContracts, undefinedContracts] = jsonData.data;

    var opts = {
      metadata: this.getMetadataFields(jsonMetadata),
      cardName: "contracts_comparison"
    };

    new ComparisonCard(
      this.container,
      temporaryContracts.value,
      undefinedContracts.value,
      opts
    );
  }
}
