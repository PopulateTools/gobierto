# frozen_string_literal: true

module GobiertoPeople
  class Setting < ApplicationRecord
    validates :key, :site_id, presence: true
    validates :key, uniqueness: { scope: :site_id }

    belongs_to :site

    default_scope { order(id: :asc) }
  end
end
