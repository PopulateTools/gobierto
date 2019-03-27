# frozen_string_literal: true

module GobiertoBudgets
  class JsonParser
    AREA_KEYS = { EconomicArea => { suffix: "", partition_field: nil },
                  FunctionalArea =>  { suffix: "-f", partition_field: :functional_code },
                  CustomArea => { suffix: "-c", partition_field: :custom_code } }.freeze

    attr_accessor :collection, :year, :kind, :site, :place, :population

    def initialize(data, decorator, options = {})
      @decorator = decorator
      collection_extractor = options[:collection_extractor] || @decorator.collection_extractor
      kind_extractor = options[:kind_extractor] || @decorator.kind_extractor
      population_extractor = options[:population_extractor] || @decorator.population_extractor
      @json = JSON.parse(data)
      @collection = collection_extractor.call(@json).map { |item| @decorator.try(:new, item) || item }
      @year = options[:year]
      @kind = @decorator.detect_kind(kind_extractor.call(@json))
      @site = options[:site]
      @place = site.place || NullObjectPlace.new
      @population = population_extractor.call(@json)
    end

    def organization_id
      site.organization_id
    end

    def collect_amounts(area, level, index, filter = nil)
      grouped_collection = @collection.group_by do |item|
        { code: item.code(area, level),
          parent_code: item.code(area, level - 1) }
      end
      grouped_collection.transform_values do |subcollection|
        subcollection = subcollection.select { |item| filter.call(item) } if filter
        subcollection.sum { |item| item.amount(index) }
      end
    end

    def base_data
      { organization_id: organization_id,
        ine_code: place.id.to_i,
        province_id: place.province.id.to_i,
        autonomy_id: place.province.autonomous_region.id.to_i,
        year: year,
        population: population }
    end

    def budgets_for(area, index)
      (1..4).map do |level|
        collect_amounts(area, level, index).map do |codes, amount|
          next if amount.round(2) == 0.0

          {
            index: {
              _index: index,
              _id: [organization_id, year, codes[:code], kind].join("/"),
              _type: area.area_name,
              data: base_data.merge(amount: amount.round(2),
                                    code: codes[:code],
                                    level: level,
                                    kind: kind,
                                    amount_per_inhabitant: population ? (amount / population).round(2) : nil,
                                    parent_code: codes[:parent_code])
            }
          }
        end
      end.flatten.compact
    end

    def economic_partitions_for(area, index)
      return if AREA_KEYS[area][:partition_field].blank?

      (1..4).map do |level|
        collect_amounts(area, level, index).map do |area_codes, _|
          partition_filter = ->(item) { item.code(area, level) == area_codes[:code] }
          collect_amounts(EconomicArea, 1, index, partition_filter).map do |economic_codes, amount|
            next if amount.round(2) == 0.0

            {
              index: {
                _index: index,
                _id: [organization_id, year, "#{area_codes[:code]}-#{economic_codes[:code]}#{AREA_KEYS[area][:suffix]}", kind].join("/"),
                _type: EconomicArea.area_name,
                data: base_data.merge(amount: amount.round(2),
                                      code: economic_codes[:code],
                                      AREA_KEYS[area][:partition_field] => area_codes[:code],
                                      level: 1,
                                      kind: kind,
                                      amount_per_inhabitant: population ? (amount / population).round(2) : nil,
                                      parent_code: economic_codes[:parent_code])
              }
            }
          end
        end
      end.flatten.compact
    end

    class NullObjectPlace
      [:a, :s, :f, :i].each do |type|
        define_method :"to_#{ type }" do
          nil
        end
      end

      def tap
        self
      end

      def nil?
        true
      end

      def present?
        false
      end

      def empty?
        true
      end

      def method_missing(*)
        self
      end
    end
  end
end
