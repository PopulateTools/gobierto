import { Card } from "./card.js";

export class SelfFinancingCapacityCard extends Card {
  constructor(divClass, city_id, current_year) {
    super(divClass);

    this.cardName = "self_financing_capacity";

    this.query = `
    WITH income AS
      (SELECT SUM(amount),
              year
      FROM presupuestos_municipales
      WHERE place_id = ${city_id}
        AND area = 'e'
        AND kind = 'I'
        AND year <= ${current_year}
        AND code IN ('1', '2', '3')
      GROUP BY year),
        income_all AS
      (SELECT SUM(amount),
              year
      FROM presupuestos_municipales
      WHERE place_id = ${city_id}
        AND area = 'e'
        AND kind = 'I'
        AND year <= ${current_year}
        AND code IN ('1', '2', '3', '4', '5')
      GROUP BY year)
    SELECT
      CONCAT(income.year, '-', 1, '-', 1) AS date,
      round((income.sum - income_all.sum) / 100), 2) AS value
    FROM income
    INNER JOIN income_all ON income_all.year = income.year
    ORDER BY income.year DESC
    LIMIT 5
    `;
  }
}
