import { Card } from "./card.js";

export class TaxAutonomyCard extends Card {
  constructor(divClass, city_id, current_year) {
    super(divClass);

    this.cardName = "tax_autonomy";

    this.query = `
      WITH income AS
        (SELECT SUM(amount),
                year
        FROM presupuestos_municipales
        WHERE place_id = ${city_id}
          AND area = 'e'
          AND kind = 'I'
          AND year <= ${current_year}
          AND code IN ('1', '2', '3', '5')
        GROUP BY year),
          income_all AS
        (SELECT SUM(amount),
                year
        FROM presupuestos_municipales
        WHERE place_id = ${city_id}
          AND area = 'e'
          AND kind = 'I'
          AND year <= ${current_year}
          AND code IN ('1', '2', '3', '4', '5', '6', '7', '8', '9')
        GROUP BY year)
      SELECT
        CONCAT(income.year, '-', 1, '-', 1) AS date,
        round((income.sum - income_all.sum) / 100), 2) AS value
      FROM income
      INNER JOIN income_all ON income_all.year = income.year
      ORDER BY income.year DESC
      LIMIT 5
      `;

    // this.url =
    //   window.populateData.endpoint +
    //   "/datasets/ds-autonomia-fiscal.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_municipality_id=" +
    //   city_id +
    //   "&date_date_range=20100101-" +
    //   this.currentYear +
    //   "1231";
  }
}
