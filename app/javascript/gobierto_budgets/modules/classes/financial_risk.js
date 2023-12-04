import { Card } from "./card.js";

export class FinancialRiskCard extends Card {
  constructor(divClass, city_id, current_year) {
    super(divClass);

    this.cardName = "financial_risk";

    this.query = `
      WITH income AS
        (SELECT SUM(amount),
                year
        FROM presupuestos_municipales
        WHERE place_id = ${city_id}
          AND area = 'e'
          AND kind = 'I'
          AND year <= ${current_year}
          AND code IN ('1', '2', '3', '4', '5')
        GROUP BY year),
      debt AS
        (SELECT value, place_id, year
        FROM deuda_municipal
        WHERE place_id = ${city_id}
          AND year <= ${current_year}
        ORDER BY year),
      expense AS
        (SELECT SUM(amount),
                year
        FROM presupuestos_municipales
        WHERE place_id = ${city_id}
          AND area = 'e'
          AND kind = 'G'
          AND year <= ${current_year}
          AND code IN ('1', '2', '3', '4')
        GROUP BY year)
      SELECT
        CONCAT(income.year, '-', 1, '-', 1) AS date,
        round((debt.value / (income.sum - expense.sum)) * 100, 2) AS value
      FROM income
      INNER JOIN expense ON expense.year = income.year
      INNER JOIN debt ON deb.year = income.year
      ORDER BY income.year DESC
      LIMIT 5
      `;

    // this.url =
    //   window.populateData.endpoint +
    //   "/datasets/ds-riesgo-financiero.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_municipality_id=" +
    //   city_id +
    //   "&date_date_range=20100101-" +
    //   this.currentYear +
    //   "1231";
  }
}
