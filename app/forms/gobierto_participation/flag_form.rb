# frozen_string_literal: true

module GobiertoParticipation
  class FlagForm < BaseForm

    attr_accessor(
      :id,
      :site_id,
      :user_id,
      :flaggable_type,
      :flaggable_id
    )

    delegate :persisted?, to: :flag

    validates :site, presence: true
    validate :contribution_container_must_be_open

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

    def comment
      flaggable_type == comment_class.to_s ? comment_class.find(flaggable_id) : nil
    end

    def contribution
      comment.commentable_type == contribution_class.to_s ? contribution_class.find(comment.commentable_id) : nil
    end

    def contribution_container
      contribution ? contribution.contribution_container : nil
    end

    private

    def build_flag
      flag_class.new
    end

    def flag_class
      ::GobiertoParticipation::Flag
    end

    def comment_class
      ::GobiertoParticipation::Comment
    end

    def contribution_class
      ::GobiertoParticipation::Contribution
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

    def contribution_container_must_be_open
      if comment.present? && contribution_container.present? && !contribution_container.contributions_allowed?
        errors.add(:contribution_container, 'Contributions period has finished')
      end
    end

  end
end
