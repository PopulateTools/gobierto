# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationForm < BaseForm

      prepend ::GobiertoCommon::Trackable

      OPENING_DATE_RANGE_SEPARATOR = " - "

      attr_accessor(
        :id,
        :admin_id,
        :site_id,
        :title,
        :description,
        :opens_on,
        :closes_on,
        :opening_date_range,
        :visibility_level,
        :show_figures,
        :force_responses_balance
      )

      delegate :persisted?, to: :consultation

      validates :title, :description, presence: true
      validates :opening_date_range, presence: true
      validates :admin, :site, presence: true

      trackable_on :consultation

      notify_changed :visibility_level

      def save
        save_consultation if valid?
      end

      def consultation
        @consultation ||= consultation_class.find_by(id: id).presence || build_consultation
      end

      def admin_id
        @admin_id ||= consultation.admin_id
      end

      def site_id
        @site_id ||= consultation.site_id
      end

      def admin
        @admin ||= Admin.find(admin_id)
      end

      def site
        @site ||= Site.find(site_id)
      end

      def visibility_level
        @visibility_level ||= "draft"
      end

      def opening_date_range
        @opening_date_range ||= begin
          [@opens_on, @closes_on]
            .compact
            .join(OPENING_DATE_RANGE_SEPARATOR)
        end
      end

      def opens_on
        @opens_on ||= opening_date_range.split(OPENING_DATE_RANGE_SEPARATOR)[0]
      end

      def closes_on
        @closes_on ||= opening_date_range.split(OPENING_DATE_RANGE_SEPARATOR)[1]
      end

      def notify?
        consultation.active?
      end

      private

      def build_consultation
        consultation_class.new
      end

      def consultation_class
        ::GobiertoBudgetConsultations::Consultation
      end

      def save_consultation
        @consultation = consultation.tap do |consultation_attributes|
          consultation_attributes.admin_id = admin_id
          consultation_attributes.site_id = site_id
          consultation_attributes.title = title
          consultation_attributes.description = description
          consultation_attributes.visibility_level = visibility_level
          consultation_attributes.opens_on = opens_on
          consultation_attributes.closes_on = closes_on
          consultation_attributes.show_figures = show_figures
          consultation_attributes.force_responses_balance = force_responses_balance
        end

        if @consultation.valid?
          run_callbacks(:save) do
            @consultation.save
          end

          @consultation
        else
          promote_errors(@consultation.errors)

          false
        end
      end

    end
  end
end
