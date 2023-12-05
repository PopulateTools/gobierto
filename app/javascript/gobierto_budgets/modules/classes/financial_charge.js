import { Card } from "./card.js";

export class FinancialChargeCard extends Card {
  constructor(divClass, city_id, current_year) {
    super(divClass);

    this.cardName = "financial_charge";

    this.query = `
      WITH expense AS
        (SELECT SUM(amount),
                year
        FROM presupuestos_municipales
        WHERE place_id = ${city_id}
          AND area = 'e'
          AND kind = 'G'
          AND year <= ${current_year}
          AND code IN ('3', '9')
        GROUP BY year),
      expense_all AS
        (SELECT SUM(amount),
                year
        FROM presupuestos_municipales
        WHERE place_id = ${city_id}
          AND area = 'e'
          AND kind = 'G'
          AND year <= ${current_year}
          AND code IN ('1', '2', '3', '4', '5', '6', '7', '8', '9')
        GROUP BY year)
      SELECT
        CONCAT(expense_all.year, '-', 1, '-', 1) AS date,
        round((expense.sum / expense_all.sum) * 100, 2) AS value
      FROM expense_all
      INNER JOIN expense ON expense.year = expense_all.year
      ORDER BY expense_all.year DESC
      LIMIT 5
      `;
  }
}
