import { effectiveTenderId } from "../../../app/javascript/gobierto_visualizations/webapp/lib/utils.js";

describe('effectiveTenderId', () => {
  describe('when the CSV carries the tender_id column', () => {
    test('returns it for a contract belonging to a tender', () => {
      expect(effectiveTenderId({ id: '1', tender_id: '4372265', minor_contract: 'f' })).toBe('4372265')
    })

    test('returns null when it is empty, without falling back to id', () => {
      expect(effectiveTenderId({ id: '1', tender_id: '', minor_contract: 't' })).toBeNull()
      expect(effectiveTenderId({ id: '1', tender_id: '', minor_contract: 'f' })).toBeNull()
    })

    test('trusts the column over the minor_contract flag', () => {
      expect(effectiveTenderId({ id: '1', tender_id: '99', minor_contract: 't' })).toBe('99')
    })
  })

  describe('when the CSV does not carry the tender_id column', () => {
    test('falls back to id for a non-minor contract', () => {
      expect(effectiveTenderId({ id: '4372265', minor_contract: 'f' })).toBe('4372265')
    })

    test('returns null for a minor contract, whose id lives in another id space', () => {
      expect(effectiveTenderId({ id: '6163088', minor_contract: 't' })).toBeNull()
    })

    test('returns null when id is empty too', () => {
      expect(effectiveTenderId({ id: '', minor_contract: 'f' })).toBeNull()
      expect(effectiveTenderId({})).toBeNull()
    })
  })
})
