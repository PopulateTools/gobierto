import { costCoverage } from "../../../app/javascript/gobierto_visualizations/webapp/lib/utils.js";

describe('costCoverage', () => {
  test('returns the percentage of the cost covered by the income', () => {
    expect(costCoverage(25, 200)).toBe(12.5)
    expect(costCoverage(300, 200)).toBe(150)
  })

  test('returns 0 when there is cost but no income', () => {
    expect(costCoverage(0, 200)).toBe(0)
  })

  test('returns null when there is no cost, instead of Infinity or NaN', () => {
    expect(costCoverage(14767279.96, 0)).toBeNull()
    expect(costCoverage(0, 0)).toBeNull()
  })
})
