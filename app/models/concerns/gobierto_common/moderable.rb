# frozen_string_literal: true

module GobiertoCommon
  module Moderable
    extend ActiveSupport::Concern

    included do
      has_one :moderation, class_name: "GobiertoAdmin::Moderation", as: :moderable, autosave: true, dependent: :destroy

      scope :with_moderation_stage, lambda { |stage|
        if stage.try(:to_sym) == :blank
          left_outer_joins(:moderation).where(admin_moderations: { stage: nil })
        else
          joins(:moderation).where(admin_moderations: { stage: moderation_stages[stage] })
        end
      }

      delegate :stage, :available_stages, :locked_edition?, to: :moderation, prefix: true


      def moderation
        super || build_moderation(stage: default_moderation_stage)
      end

      def default_moderation_stage
        :not_sent
      end

      def base_permissions_lookup_attributes(action)
        [{
          namespace: moderation.moderable_type.deconstantize.underscore,
          resource_type: moderation.moderable_type,
          resource_id: moderation.moderable_id,
          action_name: action
        }]
      end

      alias_method :permissions_lookup_attributes, :base_permissions_lookup_attributes
      private :base_permissions_lookup_attributes
    end

    class_methods do
      def extra_moderation_permissions_lookup_attributes
        define_method :permissions_lookup_attributes do |action|
          base_permissions_lookup_attributes(action) +
            yield(self, action.to_sym).map { |attrs_set| attrs_set.merge(action_name: action) }
        end
      end

      def default_moderation_stage
        define_method :default_moderation_stage do
          yield self
        end
      end

      def moderation_stages
        ::GobiertoAdmin::Moderation.stages
      end
    end
  end
end
