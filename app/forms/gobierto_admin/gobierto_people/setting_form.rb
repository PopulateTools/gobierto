module GobiertoAdmin
  module GobiertoPeople
    class SettingForm
      include ActiveModel::Model

      attr_accessor(
        :id,
        :value
      )

      delegate :persisted?, to: :setting

      def save
        save_setting if valid?
      end

      def setting
        @setting ||= setting_class.find_by(id: id).presence || build_setting
      end

      private

      def build_setting
        setting_class.new
      end

      def setting_class
        ::GobiertoPeople::Setting
      end

      def save_setting
        @setting = setting.tap do |setting_attributes|
          setting_attributes.value = value
        end

        if @setting.valid?
          @setting.save

          @setting
        else
          promote_errors(@setting.errors)

          false
        end
      end

      protected

      def promote_errors(errors_hash)
        errors_hash.each do |attribute, message|
          errors.add(attribute, message)
        end
      end
    end
  end
end
