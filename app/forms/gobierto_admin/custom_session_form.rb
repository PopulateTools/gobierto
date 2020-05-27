# frozen_string_literal: true

class GobiertoAdmin::CustomSessionForm < BaseForm

  attr_accessor(
    :site,
    :creation_ip,
    :data
  )

  validates :site, presence: true
  validates :admin, presence: true

  attr_reader :admin

  def save
    valid? && admin.valid?
  end

  def authentication_data_invalid?
    false
  end
end
