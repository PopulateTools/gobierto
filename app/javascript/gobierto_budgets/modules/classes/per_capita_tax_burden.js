import { Card } from './card.js';

export class PerCapitaTaxBurdenCard extends Card {
  constructor(divClass, city_id, current_year) {
    super(divClass);

    this.cardName = "per_capita_tax_burden";

    this.query = `
    WITH population AS
      (SELECT year, SUM(total::integer) AS sum FROM poblacion_edad_sexo
      WHERE place_id=${city_id} AND sex='Total' AND year <= ${current_year}
      GROUP BY year
      ORDER BY year DESC),
    income AS
      (SELECT SUM(amount),
              year
      FROM presupuestos_municipales
      WHERE place_id = ${city_id}
        AND area = 'e'
        AND kind = 'I'
        AND year <= ${current_year}
        AND code IN ('1', '2', '3')
      GROUP BY year)
    SELECT
      CONCAT(population.year, '-', 1, '-', 1) AS date,
      round((income.sum / population.sum), 2) AS value
    FROM population
    INNER JOIN income ON income.year = population.year
    ORDER BY population.year DESC
    LIMIT 5
    `;
  }
}
