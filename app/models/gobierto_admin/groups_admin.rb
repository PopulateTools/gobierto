# frozen_string_literal: true

module GobiertoAdmin
  class GroupsAdmin < ApplicationRecord
    belongs_to :admin
    belongs_to :admin_group
  end
end
