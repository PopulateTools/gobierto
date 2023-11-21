import { Card } from "./card.js";

export class TaxAutonomyCard extends Card {
  constructor(divClass, city_id, current_year) {
    super(divClass, current_year);

    this.cardName = "tax_autonomy"

    this.url =
      window.populateData.endpoint +
      `
      WITH income AS
        (SELECT SUM(amount),
                year
        FROM presupuestos_municipales
        WHERE place_id = ${city_id}
          AND area = 'e'
          AND kind = 'I'
          AND code IN ('1',
                        '2',
                        '3',
                        '4',
                        '5')
        GROUP BY year),
          expense AS
        (SELECT SUM(amount),
                year
        FROM presupuestos_municipales
        WHERE place_id = ${city_id}
          AND area = 'e'
          AND kind = 'G'
          AND code IN ('1',
                        '2',
                        '3',
                        '4')
        GROUP BY year)
      SELECT
        CONCAT(income.year, '-', 1, '-', 1) AS date,
        income.sum - expense.sum AS value
      FROM income
      INNER JOIN expense ON expense.year = income.year
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
