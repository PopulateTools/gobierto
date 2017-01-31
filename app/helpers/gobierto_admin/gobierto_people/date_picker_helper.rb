module GobiertoAdmin
  module GobiertoPeople
    module DatePickerHelper
      def format_time(form, attribute, time_offset = 1)
        (form.object.send(attribute.to_sym).try(:to_time) || (time_offset.hour.from_now + 1.day).beginning_of_hour.localtime).iso8601
      end
    end
  end
end
