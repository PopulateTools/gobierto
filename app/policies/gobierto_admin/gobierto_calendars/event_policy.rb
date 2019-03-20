module GobiertoAdmin
  module GobiertoCalendars
    class EventPolicy < ::GobiertoAdmin::BasePolicy

      attr_reader :event, :collection, :container

      def initialize(attributes)
        super(attributes)
        @event = attributes[:event]
        set_collection(attributes)
        set_container
      end

      def manage?
        if current_admin.regular?
          can_manage_container?
        else
          return super
        end
      end

      def view?
        (event && container && event.active? && container.active?) || manage?
      end

      def create?
        manage?
      end

      private

      def can_manage_container?
        if container.is_a?(::GobiertoPeople::Person)
          GobiertoPeople::PersonPolicy.new(
            current_admin: current_admin,
            current_site: current_site,
            person: container
          ).manage?
        else  # => process?
          true
        end
      end

      def set_collection(attributes)
        if event
          @collection = current_site.collections.find(event.collection_id)
        elsif attributes[:collection_id]
          @collection = current_site.collections.find(attributes[:collection_id])
        else
          @collection = nil
        end
      end

      def set_container
        @container = collection ? collection.container : nil
      end

    end
  end
end