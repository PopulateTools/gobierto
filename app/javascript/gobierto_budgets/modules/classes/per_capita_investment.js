import { Card } from './card.js';

export class PerCapitaInvestmentCard extends Card {
  constructor(divClass, city_id, current_year) {
    super(divClass);

    this.cardName = "per_capita_investment";

    this.query = `
      WITH population AS
        (SELECT year, SUM(total::integer) AS sum
        FROM poblacion_edad_sexo
        WHERE place_id=${city_id} AND sex='Total' AND year <= ${current_year}
        GROUP BY year
        ORDER BY year DESC),
      expense AS
        (SELECT SUM(amount), year
        FROM presupuestos_municipales
        WHERE place_id = ${city_id}
          AND area = 'e'
          AND kind = 'G'
          AND year <= ${current_year}
          AND code IN ('6', '7')
        GROUP BY year)
      SELECT
        CONCAT(population.year, '-', 1, '-', 1) AS date,
        round((expense.sum / population.sum), 2) AS value
      FROM population
      INNER JOIN expense ON expense.year = population.year
      ORDER BY population.year DESC
      LIMIT 5
      `;
  }
}
