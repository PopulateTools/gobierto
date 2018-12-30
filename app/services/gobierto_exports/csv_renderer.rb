module GobiertoExports
  class CSVRenderer
    def initialize(relation, options={})
      @relation = relation
      @options = options
    end

    def to_csv
      CSV.generate do |csv|
        columns =  if @relation.respond_to? :klass
                     @relation.klass.csv_columns
                   else
                     @relation.first.class.csv_columns
                   end
        csv << columns
        @relation.each do |record|
          csv << record.as_csv
        end
      end.force_encoding('utf-8')
    end
  end
end
