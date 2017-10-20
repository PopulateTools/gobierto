module GobiertoAdmin
  module GobiertoPeople
    class PersonPolicy < ::GobiertoAdmin::BasePolicy

      attr_reader :person

      def initialize(attributes)
        super(attributes)
        @person = attributes[:person]
      end

      def manage?
        if current_admin.regular?
          can_manage_site?(person.site) &&
          can_manage_module?('GobiertoPeople') &&
          can_manage_person?(person)
        else
          return super
        end
      end

      def view?
        (person && person.active?) || manage?
      end

      def create?
        current_admin.manager?
      end

      def manage_all_people_in_site?
        return true if current_admin.manager?
        site_people_ids = current_site.people.pluck(:id)
        permitted_site_people_ids = current_admin.people_permissions.where(resource_id: site_people_ids)
        site_people_ids.size == permitted_site_people_ids.size
      end

      private

      def can_manage_person?(person)
        current_admin.people_permissions.exists?(
          resource_id: person.id,
          action_name: 'manage'
        )
      end

    end
  end
end