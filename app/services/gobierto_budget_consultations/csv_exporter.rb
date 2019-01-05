module GobiertoBudgetConsultations
  class CsvExporter
    def self.export(consultation)
      attributes = %w{ id age gender location question answer }

      CSV.generate(headers: true) do |csv|
        csv << attributes

        consultation.consultation_responses.sorted.each do |consultation_response|
          gender = consultation_response.user_information['gender'] rescue nil
          age = ((Date.today - Date.parse(consultation_response.user_information['date_of_birth'])).to_i / 365.0).floor rescue nil
          location = consultation_response.user_information['place']['raw_value'] rescue nil

          consultation_response.consultation_items.each do |item|
            csv << [ consultation_response.id, age, gender, location, item.item_title.strip, item.selected_option ]
          end
        end
      end.force_encoding('utf-8')
    end
  end
end
