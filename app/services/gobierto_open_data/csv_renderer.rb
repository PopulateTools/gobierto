module GobiertoOpenData
  class CSVRenderer
    def initialize(relation, options={})
      @relation = relation
      @options = options
    end

    def to_csv
      csv = CSV.generate do |csv|
        csv << @relation.attribute_names
        @relation.each do |record|
          csv << record.attributes.values
        end
      end
    end
  end
end
