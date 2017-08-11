# frozen_string_literal: true

AlgoliaSearch.configuration = {
  application_id: Rails.application.secrets.algolia_application_id || "",
  api_key: Rails.application.secrets.algolia_api_key || "",
  connect_timeout: 2,
  receive_timeout: 30,
  send_timeout: 30,
  batch_timeout: 120,
  search_timeout: 5,
  pagination_backend: :kaminari
}
