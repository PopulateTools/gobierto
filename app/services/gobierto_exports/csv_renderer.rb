module GobiertoExports
  class CSVRenderer
    def initialize(relation, options={})
      @relation = relation
      @options = options
    end

    def to_csv
      csv = CSV.generate do |csv|
        csv << @relation.klass.csv_columns
        @relation.each do |record|
          csv << record.as_csv
        end
      end
    end
  end
end
