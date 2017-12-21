# frozen_string_literal: true

class User::CustomSessionForm
  include ActiveModel::Model

  attr_accessor(
    :site,
    :creation_ip,
    :referrer_url,
    :referrer_entity,
    :callback_url,
    :data
  )

  validates :site, presence: true
  validates :user, presence: true

  attr_reader :user

  def save
    valid? && user.valid?
  end

  def callback_url
    @callback_url ||= Rails.application.routes.url_helpers.root_url(host: site.domain, referrer: referrer_url)
  end

  def authentication_data_invalid?
    false
  end

end
