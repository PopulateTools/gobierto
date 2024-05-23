import { Card } from './card.js';

export class NetSavingCard extends Card {
  constructor(divClass, city_id, current_year) {
    super(divClass);

    this.cardName = "net_saving";

    this.query = `
      WITH income AS
        (SELECT SUM(amount), year
        FROM presupuestos_municipales
        WHERE place_id = ${city_id}
          AND area = 'e'
          AND kind = 'I'
          AND year <= ${current_year}
          AND code IN ('1', '2', '3', '4', '5')
        GROUP BY year),
      expense AS
        (SELECT SUM(amount), year
        FROM presupuestos_municipales
        WHERE place_id = ${city_id}
          AND area = 'e'
          AND kind = 'G'
          AND year <= ${current_year}
          AND code IN ('1', '2', '3', '4')
        GROUP BY year),
      expense_9 AS
        (SELECT amount, year
        FROM presupuestos_municipales
        WHERE place_id = ${city_id}
          AND area = 'e'
          AND kind = 'G'
          AND code = '9'
      )
      SELECT
        CONCAT(income.year, '-', 1, '-', 1) AS date,
        income.sum - expense.sum + expense_9.amount AS value
      FROM income
      INNER JOIN expense ON expense.year = income.year
      INNER JOIN expense_9 ON expense_9.year = income.year
      ORDER BY income.year DESC
      LIMIT 5
      `;
  }
}
