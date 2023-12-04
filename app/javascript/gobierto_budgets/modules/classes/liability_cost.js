import { Card } from "./card.js";

export class LiabilityCostCard extends Card {
  constructor(divClass, city_id, current_year) {
    super(divClass);

    this.cardName = "liability_cost";

    this.query = `
      WITH expense AS
        (SELECT amount,
                year
        FROM presupuestos_municipales
        WHERE place_id = ${city_id}
          AND area = 'e'
          AND kind = 'G'
          AND year <= ${current_year}
          AND code IN ('3')
        GROUP BY year),
      debt AS
        (SELECT value, place_id, year
        FROM deuda_municipal
        WHERE place_id = ${city_id}
          AND year <= ${current_year}
        ORDER BY year)
      SELECT
        CONCAT(expense.year, '-', 1, '-', 1) AS date,
        round((expense.amount / debt.value) * 100, 2) AS value
      FROM expense
      INNER JOIN debt ON expense.year = debt.year
      ORDER BY expense.year DESC
      LIMIT 5
      `;

    // this.url =
    //   window.populateData.endpoint +
    //   "/datasets/ds-coste-deuda.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_municipality_id=" +
    //   city_id +
    //   "&date_date_range=20100101-" +
    //   this.currentYear +
    //   "1231";
  }
}
