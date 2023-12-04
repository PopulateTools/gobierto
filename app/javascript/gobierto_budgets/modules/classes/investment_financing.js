import { Card } from "./card.js";

export class InvestmentFinancingCard extends Card {
  constructor(divClass, city_id, current_year) {
    super(divClass);

    this.cardName = "investment_financing";

    this.query = `
      WITH income AS
        (SELECT SUM(amount),
                year
        FROM presupuestos_municipales
        WHERE place_id = ${city_id}
          AND area = 'e'
          AND kind = 'I'
          AND year <= ${current_year}
          AND code IN ('6', '7')
        GROUP BY year),
      expense AS
        (SELECT SUM(amount),
                year
        FROM presupuestos_municipales
        WHERE place_id = ${city_id}
          AND area = 'e'
          AND kind = 'G'
          AND year <= ${current_year}
          AND code IN ('6', '7')
        GROUP BY year)
      SELECT
        CONCAT(income.year, '-', 1, '-', 1) AS date,
        round((income.sum / expense.sum) * 100, 2) AS value
      FROM income
      INNER JOIN expense ON expense.year = income.year
      ORDER BY income.year DESC
      LIMIT 5
      `;

    // this.url =
    //   window.populateData.endpoint +
    //   "/datasets/ds-financiacion-inversiones.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_municipality_id=" +
    //   city_id +
    //   "&date_date_range=20100101-" +
    //   this.currentYear +
    //   "1231";
  }
}
