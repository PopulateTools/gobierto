module GobiertoBudgets
  class SearchEngine
    def self.client
      @client ||= Elasticsearch::Client.new log: false, url: Rails.application.secrets.elastic_url
    end
  end
end
