require 'rails_helper'

RSpec.describe GobiertoParticipation::ConsultationAnswer, type: :model do
  before do
    @site = create_site
    @user = create_user
    @commenter = create_commenter
  end


  it "shouldn't be created if the consultation has been closed" do
    consultation = create_gobierto_participation_open_answers_consultation site: @site, user: @user, open_until: 3.months.ago

    answer = consultation.answers.new user: @commenter, answer: 'Whatever the answer is'
    expect(answer).not_to be_valid
    expect(answer.errors[:consultation]).not_to be_empty
  end

  it "shouldn't be created if the consultation is open and doesn't have an answer" do
    consultation = create_gobierto_participation_open_answers_consultation site: @site, user: @user, open_until: 3.months.from_now

    answer = consultation.answers.new user: @commenter, answer: ''
    expect(answer).not_to be_valid
    expect(answer.errors[:answer]).not_to be_empty
  end
end
