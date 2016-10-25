module GobiertoBudgets
  class Place
    def self.search(query)
      return [] if query.blank? || query.length < 3

      query = {
        query: {
          multi_match: {
            type: "phrase_prefix",
            fields: ['name', 'slug'],
            query: "#{query.downcase}",
            slop: 3
          }
        },
        size: 25
      }

      response = SearchEngine.client.search index: SearchEngineConfiguration::Data.index, type: SearchEngineConfiguration::Data.type_places, body: query

      response['hits']['hits'].map{|h| h['_source'] }.map do |place|
        ine_place = INE::Places::Place.find(place['ine_code'])
        next if ine_place.nil?

        {
          value: ine_place.name,
          data: {
            category: ine_place.province.name,
            id: ine_place.id,
            slug: ine_place.slug,
            type: 'Place'
          }
        }
      end.compact
    end
  end
end
