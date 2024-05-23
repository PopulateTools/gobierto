import { Card } from './card.js';

export class DebtLevelCard extends Card {
  constructor(divClass, city_id, current_year) {
    super(divClass);

    this.cardName = "debt_level";

    this.query = `
      WITH debt AS (
        SELECT value::numeric, place_id, year
        FROM deuda_municipal
        WHERE place_id = ${city_id}
          AND year <= ${current_year}
        ORDER BY year
      ),
      expense AS (
        SELECT SUM(amount), year
        FROM presupuestos_municipales
        WHERE place_id = ${city_id}
          AND area = 'e'
          AND kind = 'G'
          AND year <= ${current_year}
          AND code IN ('1', '2', '3', '4', '5')
        GROUP BY year
      )
      SELECT
        CONCAT(expense.year, '-', 1, '-', 1) AS date,
        round((debt.value / expense.sum) * 100, 2) AS value
      FROM debt
      INNER JOIN expense ON expense.year = debt.year
      ORDER BY expense.year DESC
      LIMIT 5
      `;
  }
}
