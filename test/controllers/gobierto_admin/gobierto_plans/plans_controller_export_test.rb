# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class PlansControllerExportTest < GobiertoControllerTest
      def setup
        super
        import_plan
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def plan_type
        @plan_type ||= gobierto_plans_plan_types(:pam)
      end

      def plan
        @plan ||= site.plans.create(
          title: "My plan",
          introduction: "It's a plan",
          year: 2222,
          plan_type: plan_type,
          slug: "the-mega-plan",
          categories_vocabulary: categories_vocabulary,
          statuses_vocabulary: statuses_vocabulary
        )
      end

      def sample_import_csv_file
        @sample_import_csv_file ||= Rails.root.join("test/fixtures/files/gobierto_plans/plan3.csv")
      end

      def statuses_vocabulary
        @statuses_vocabulary ||= gobierto_common_vocabularies(:plan_csv_import_statuses_vocabulary)
      end

      def categories_vocabulary
        @categories_vocabulary = site.vocabularies.create(name: "Categories")
      end

      def locale
        @locale ||= :en
      end

      def other_locale
        @other_locale ||= :es
      end

      def import_plan
        I18n.with_locale(locale) do
          GobiertoAdmin::GobiertoPlans::PlanDataForm.new(
            csv_file: sample_import_csv_file,
            plan: plan
          ).save
        end
      end

      def test_export_csv_with_same_locale
        with(site: site, admin: admin) do
          get admin_plans_plan_export_csv_url(plan, locale: locale)

          assert_response :success
          assert_equal "text/csv", response.content_type

          parsed_response = CSV.parse(response.body, headers: true)

          assert_equal plan.nodes.count, parsed_response.length

          parsed_response.each do |row|
            assert row["Node.external_id"].present?
            node = plan.nodes.find_by(external_id: row["Node.external_id"])

            assert_equal row["Node.Title"], node.send("name_#{locale}")
            assert_equal row["Node.Status"], node.status.send("name_#{locale}")
          end

          exported_external_ids = parsed_response.map { |row| row["Node.external_id"] }

          refute_equal exported_external_ids, plan.nodes.map(&:external_id).sort
          assert_equal exported_external_ids, plan.nodes.map { |node| node.external_id.to_i }.sort.map(&:to_s)
        end
      end

      # If the value for the current locale is blank then the first locale with
      # value is used
      def test_export_csv_with_different_locale
        with(site: site, admin: admin) do
          get admin_plans_plan_export_csv_url(plan, locale: other_locale)

          assert_response :success
          assert_equal "text/csv", response.content_type

          parsed_response = CSV.parse(response.body, headers: true)

          assert_equal plan.nodes.count, parsed_response.length

          parsed_response.each do |row|
            assert row["Node.external_id"].present?
            node = plan.nodes.find_by(external_id: row["Node.external_id"])

            assert_equal row["Node.Title"], node.send("name_#{locale}")
            assert_equal row["Node.Status"], node.status.send("name_#{other_locale}")
          end

          exported_external_ids = parsed_response.map { |row| row["Node.external_id"] }

          refute_equal exported_external_ids, plan.nodes.map(&:external_id).sort
          assert_equal exported_external_ids, plan.nodes.map { |node| node.external_id.to_i }.sort.map(&:to_s)
        end
      end

      def test_export_csv_not_numeric_external_ids
        plan.nodes.each do |node|
          node.update_attribute(:external_id, "#{node.external_id}x")
        end

        with(site: site, admin: admin) do
          get admin_plans_plan_export_csv_url(plan, locale: locale)

          assert_response :success
          assert_equal "text/csv", response.content_type

          parsed_response = CSV.parse(response.body, headers: true)

          assert_equal plan.nodes.count, parsed_response.length

          parsed_response.each do |row|
            assert row["Node.external_id"].present?
            node = plan.nodes.find_by(external_id: row["Node.external_id"])

            assert_equal row["Node.Title"], node.send("name_#{locale}")
            assert_equal row["Node.Status"], node.status.send("name_#{locale}")
          end

          exported_external_ids = parsed_response.map { |row| row["Node.external_id"] }

          assert_equal exported_external_ids, plan.nodes.map(&:external_id).sort
          refute_equal exported_external_ids, plan.nodes.map { |node| node.external_id.to_i }.sort.map(&:to_s)
        end
      end
    end
  end
end
