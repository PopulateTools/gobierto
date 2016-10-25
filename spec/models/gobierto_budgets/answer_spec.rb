require 'rails_helper'

RSpec.describe GobiertoBudgets::Answer, type: :model do
  describe '.percentages_for_question' do
    it 'should return a hash with the percentages' do
      madrid_attributes = {question_id: 2, user_id: 1, place_id: 28079, year: 2015, code: '1', area_name: 'economic', kind: 'G'}
      valencia_attributes = {question_id: 2, user_id: 1, place_id: 46075, year: 2015, code: '1', area_name: 'economic', kind: 'G'}

      GobiertoBudgets::Answer.create({answer_text: 'Apropiado'}.merge(valencia_attributes))
      GobiertoBudgets::Answer.create({answer_text: 'Apropiado'}.merge(madrid_attributes))
      GobiertoBudgets::Answer.create({answer_text: 'Apropiado'}.merge(madrid_attributes))
      GobiertoBudgets::Answer.create({answer_text: 'Poco'}.merge(madrid_attributes))
      GobiertoBudgets::Answer.create({answer_text: 'Poco'}.merge(madrid_attributes.merge({code: 2})))

      percentages = GobiertoBudgets::Answer.percentages_for_question(2, {year: 2015, place_id: 28079, code: '1', area_name: 'economic', kind: 'G'})
      expect(percentages['Poco']).to eq(33.3)
      expect(percentages['Apropiado']).to eq(66.7)
      expect(percentages['Mucho']).to be_nil
    end
  end
end
