# frozen_string_literal: true

require "test_helper"

class TablePluginTest < ActionDispatch::IntegrationTest

  def site
    @site ||= sites(:madrid)
  end

  def admin
    @admin ||= gobierto_admin_admins(:natasha)
  end

  def project
    @project ||= gobierto_plans_nodes(:political_agendas)
  end

  def plan
    @plan ||= gobierto_plans_plans(:strategic_plan)
  end

  def custom_field_record
    gobierto_common_custom_field_records(:political_agendas_table_custom_field_record)
  end

  def clear_payload
    custom_field_record.update_attributes!(payload: { human_resources: [] })
  end

  def set_payload
    custom_field_record.update_attributes!(
      payload: {}
    )
  end

  def test_show
    with(site: site, js: true, admin: admin) do
      visit edit_admin_plans_plan_project_path(plan, project)

    end
  end
end
