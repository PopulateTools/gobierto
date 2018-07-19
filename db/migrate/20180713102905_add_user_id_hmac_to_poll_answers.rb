# frozen_string_literal: true

class AddUserIdHmacToPollAnswers < ActiveRecord::Migration[5.2]

  def change
    add_column :gpart_poll_answers, :user_id_hmac, :string, null: true
  end

end
