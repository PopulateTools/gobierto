module GobiertoAdmin
  module GobiertoPeople
    class PersonPolicy < ::GobiertoAdmin::BasePolicy

      attr_reader :person

      def initialize(attributes)
        super(attributes)
        @person = attributes[:person]
        @current_site ||= person.site
      end

      def manage?
        if current_admin.regular?
          manage_all_people_in_site? || (
            can_manage_site?(person.site) &&
            can_manage_module?('GobiertoPeople') &&
            can_manage_person?(person)
          )
        else
          return super
        end
      end

      def view?
        (person && person.active?) || manage?
      end

      def create?
        current_admin.manager? || manage_all_people_in_site?
      end

      def manage_all_people_in_site?
        current_admin.manager? || (has_site_permissions? && can_manage_module?('GobiertoPeople') && manage_all_people?)
      end

      private

      def can_manage_person?(person)
        current_admin.sites_people_permissions.on_site(current_site).exists?(
          resource_id: person.id,
          action_name: 'manage'
        )
      end

      def has_site_permissions?
        site_id = person.present? ? person.site.id : current_site.id
        current_admin.sites.exists?(site_id)
      end

      def manage_all_people?
        return true if current_admin.manager?
        current_admin.people_permissions.on_site(current_site).exists?(
          action_name: 'manage_all'
        )
      end

    end
  end
end