# frozen_string_literal: true

class UpdatePollAnswerUserIdConstraints < ActiveRecord::Migration[5.2]

  def up
    change_column :gpart_poll_answers, :user_id_hmac, :string, null: false
    remove_column :gpart_poll_answers, :user_id
  end

  def down
    change_column :gpart_poll_answers, :user_id_hmac, :string, null: true
    add_column :gpart_poll_answers, :user_id, :bigint

    User.all.each do |user|
      ::GobiertoParticipation::PollAnswer.by_user(user).each do |answer|
        answer.update_attribute(:user_id, user.id)
      end
    end

    change_column :gpart_poll_answers, :user_id, :bigint, null: false
  end

end
