import { contractRoutingId } from "../../../app/javascript/gobierto_visualizations/webapp/lib/utils.js";

describe('contractRoutingId', () => {
  test('returns contract_id, unique per contract, when the column is there', () => {
    expect(contractRoutingId({ id: '4372265', contract_id: '10031368' })).toBe('10031368')
  })

  test('tells apart two derived contracts sharing the same effective tender', () => {
    const first = { id: '4372265', contract_id: '6163088' }
    const second = { id: '4372265', contract_id: '10031368' }

    expect(contractRoutingId(first)).not.toBe(contractRoutingId(second))
  })

  test('falls back to id when the CSV does not carry the column', () => {
    expect(contractRoutingId({ id: '43430' })).toBe('43430')
  })

  test('falls back to id when the column is there but empty', () => {
    expect(contractRoutingId({ id: '43430', contract_id: '' })).toBe('43430')
  })
})
