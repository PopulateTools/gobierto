# frozen_string_literal: true

module GobiertoParticipation
  class CommentForm < BaseForm

    attr_accessor(
      :id,
      :site_id,
      :user_id,
      :commentable_type,
      :commentable_id,
      :body
    )

    delegate :persisted?, to: :comment

    validates :site, presence: true
    validate :contribution_container_must_be_open

    def save
      save_comment if valid?
    end

    def comment
      @comment ||= comment_class.find_by(id: id).presence || build_comment
    end

    def site_id
      @site_id ||= comment.site_id
    end

    def site
      @site ||= Site.find_by(id: site_id)
    end

    def contribution
      commentable_type == contribution_class.to_s ? contribution_class.find(commentable_id) : nil
    end

    def contribution_container
      contribution ? contribution.contribution_container : nil
    end

    private

    def build_comment
      comment_class.new
    end

    def comment_class
      ::GobiertoParticipation::Comment
    end

    def contribution_class
      ::GobiertoParticipation::Contribution
    end

    def save_comment
      @comment = comment.tap do |comment_attributes|
        comment_attributes.site_id = site_id
        comment_attributes.user_id = user_id
        comment_attributes.commentable_type = commentable_type
        comment_attributes.commentable_id = commentable_id
        comment_attributes.body = body
      end

      if @comment.valid?
        @comment.save

        @comment
      else
        promote_errors(@comment.errors)

        false
      end
    end

    def contribution_container_must_be_open
      if contribution_container.present? && !contribution_container.contributions_allowed?
        errors.add(:contribution_container, 'Contributions period has finished')
      end
    end

  end
end
