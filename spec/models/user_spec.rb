require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#full_name' do
    it 'should include first name and last name' do
      user = create_user first_name: 'Foo', last_name: 'Wadus'
      expect(user.full_name).to eq('Foo Wadus')
    end
  end
end
