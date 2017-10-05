module GobiertoAdmin
  module GobiertoPeople
    class PersonPolicy

      attr_reader :admin_user, :person

      def initialize(admin_user, person = nil)
        @admin_user = admin_user
        @person = person
      end

      def manage?
        return false if admin_user.disabled?
        return true  if admin_user.manager?
        return (
          can_manage_site?(person.site) &&
          can_manage_module?('GobiertoPeople') &&
          can_manage_person?(person)
        ) if admin_user.regular?
      end

      def view?
        person.active? || manage?
      end

      def create?
        admin_user.manager?
      end

      private

      def can_manage_site?(site)
        admin_user.sites.exists?(site.id)
      end

      def can_manage_module?(module_namespace)
        admin_user.module_allowed?(module_namespace)
      end

      def can_manage_person?(person)
        admin_user.people_permissions.exists?(
          resource_id: person.id,
          action_name: 'manage'
        )
      end

    end
  end
end