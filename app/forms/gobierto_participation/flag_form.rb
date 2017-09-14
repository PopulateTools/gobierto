# frozen_string_literal: true

module GobiertoParticipation
  class FlagForm
    include ActiveModel::Model

    attr_accessor(
      :id,
      :site_id,
      :user_id,
      :flaggable_type,
      :flaggable_id
    )

    delegate :persisted?, to: :flag

    validates :site, presence: true

    def save
      save_flag if valid?
    end

    def flag
      @flag ||= flag_class.find_by(id: id).presence || build_flag
    end

    def site_id
      @site_id ||= flag.site_id
    end

    def site
      @site ||= Site.find_by(id: site_id)
    end

    private

    def build_flag
      flag_class.new
    end

    def flag_class
      ::GobiertoParticipation::Flag
    end

    def save_flag
      @flag = flag.tap do |flag_attributes|
        flag_attributes.site_id = site_id
        flag_attributes.user_id = user_id
        flag_attributes.flaggable_type = flaggable_type
        flag_attributes.flaggable_id = flaggable_id
      end

      if @flag.valid?
        @flag.save

        @flag
      else
        promote_errors(@flag.errors)

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
