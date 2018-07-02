# frozen_string_literal: true

module GobiertoPeople
  module Departments
    class BaseController < GobiertoPeople::ApplicationController

      helper_method :current_department

      before_action :check_active_submodules

      protected

      def current_department
        @current_department ||= current_site.departments.find_by!(slug: params[:department_slug])
      end

      private

      def check_active_submodules
        redirect_to gobierto_people_root_path unless departments_submodule_active?
      end

    end
  end
end
