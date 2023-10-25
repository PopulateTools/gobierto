# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  module Api
    module V1
      class PlansControllerTest < GobiertoControllerTest
        def site
          @site ||= sites(:madrid)
        end

        def admin
          @admin ||= admins(:natasha)
        end

        def admin_token
          @admin_token ||= "Bearer #{gobierto_admin_api_tokens(:natasha_primary_api_token).token}"
        end

        def user_token
          @user_token ||= "Bearer #{user_api_tokens(:peter_primary_api_token).token}"
        end

        def plan
          @plan ||= gobierto_plans_plans(:government_plan)
        end

        def plan_type
          @plan_type ||= gobierto_plans_plan_types(:pam)
        end

        def other_plan
          @other_plan ||= gobierto_plans_plans(:strategic_plan)
        end

        def draft_plan
          @draft_plan ||= gobierto_plans_plans(:economic_plan)
        end

        def new_plan_categories_vocabulary
          @new_plan_categories_vocabulary ||= gobierto_common_vocabularies(:new_plan_categories_vocabulary)
        end

        def new_plan_statuses_vocabulary
          @new_plan_statuses_vocabulary ||= gobierto_common_vocabularies(:plan_projects_statuses_vocabulary)
        end

        def other_plan_project
          @other_plan_project ||= gobierto_plans_nodes(:political_agendas)
        end

        def other_plan_draft_project
          @other_plan_draft_project ||= gobierto_plans_nodes(:scholarships_kindergartens)
        end

        def plans_count
          @plans_count ||= site.plans.published.count
        end

        def public_attributes_data(plan)
          %w(slug title introduction year visibility_level css footer configuration_data).each_with_object({}) do |k, values|
            values[k] = plan.send(k)
          end.with_indifferent_access
        end

        def admin_attributes_data(plan)
          %w(slug title_translations introduction_translations configuration_data year visibility_level css footer_translations).each_with_object({}) do |k, values|
            values[k] = plan.send(k)
          end.with_indifferent_access
        end

        def invalid_params
          {
            data:
            {
              type: "gobierto_plans-plans",
              attributes:
              {
                "title_translations": nil,
                "slug": nil
              }
            }
          }
        end

        def valid_params_with_existing_vocabularies
          {
            data: {
              type: "gobierto_plans-plans",
              attributes: {
                "slug": "new-plan-from-api",
                "title_translations": {
                  "en": "New plan from API",
                  "es": "Nuevo plan desde la API"
                },
                "introduction_translations": {
                  "en": "New plan from API (description)",
                  "es": "Nuevo plan desde la API (descripción)"
                },
                "categories_vocabulary": new_plan_categories_vocabulary.slug,
                "statuses_vocabulary": new_plan_statuses_vocabulary.id,
                "configuration_data": {
                  "level0": {
                    "one": {
                      "en": "axe",
                      "es": "eje"
                    },
                    "other": {
                      "en": "axes",
                      "es": "ejes"
                    }
                  },
                  "level1": {
                    "one": {
                      "en": "actuation line",
                      "es": "línea de actuación"
                    },
                    "other": {
                      "en": "actuation lines",
                      "es": "líneas de actuación"
                    }
                  },
                  "level0_options": [],
                  "show_table_header": false,
                  "open_node": false
                },
                "year": 2025,
                "visibility_level": "published",
                "css": ".gobierto_planification section.level_0 .cat_1 {
                          background-color: rgba(0, 191, 255, 0.95);
                        }",
                "footer_translations": { "en": "Footer", "es": "Pie" }
              }
            }
          }
        end

        def valid_params_with_existing_vocabularies_and_new_items
          {
            data: {
              type: "gobierto_plans-plans",
              attributes: {
                "slug": "new-plan-from-api",
                "title_translations": {
                  "en": "New plan from API",
                  "es": "Nuevo plan desde la API"
                },
                "introduction_translations": {
                  "en": "New plan from API (description)",
                  "es": "Nuevo plan desde la API (descripción)"
                },
                "categories_vocabulary": new_plan_categories_vocabulary.slug,
                "statuses_vocabulary": new_plan_statuses_vocabulary.id,
                "configuration_data": {
                  "level0": {
                    "one": {
                      "en": "axe",
                      "es": "eje"
                    },
                    "other": {
                      "en": "axes",
                      "es": "ejes"
                    }
                  },
                  "level1": {
                    "one": {
                      "en": "actuation line",
                      "es": "línea de actuación"
                    },
                    "other": {
                      "en": "actuation lines",
                      "es": "líneas de actuación"
                    }
                  },
                  "level0_options": [],
                  "show_table_header": false,
                  "open_node": false
                },
                "year": 2025,
                "visibility_level": "published",
                "css": ".gobierto_planification section.level_0 .cat_1 {
                          background-color: rgba(0, 191, 255, 0.95);
                        }",
                "footer_translations": { "en": "Footer", "es": "Pie" },
                "categories_vocabulary_terms": [
                  {
                    "name_translations": {
                      "en": "New term 1",
                      "es": "Nuevo termino 1"
                    },
                    "description_translations": {
                      "en": "New term 1 desc",
                      "es": "Nuevo termino 1 desc"
                    },
                    "slug": "term-slug",
                    "position": 0,
                    "level": 0,
                    "parent_id": "3",
                    "external_id": "EXT"
                  }
                ],
                "statuses_vocabulary_terms": [
                  {
                    "name_translations": {
                      "en": "Status A",
                      "es": "Status A"
                    },
                    "description_translations": {
                      "en": "This is the A status",
                      "es": "This is the A status"
                    },
                    "slug": "status-a-slug",
                    "position": 0,
                    "level": 0,
                    "parent_id": nil,
                    "external_id": "ST000A"
                  },
                ],
                "projects": [
                  {
                    "external_id": "PRJ-1",
                    "visibility_level": "published",
                    "moderation_stage": "approved",
                    "name_translations": {
                      "en": "The very first project",
                      "es": "El primerísimo proyecto"
                    },
                    "category_external_id": "EXT",
                    "status_external_id": "ST000A",
                    "progress": 100.0
                  },
                  {
                    "external_id": "PRJ-2",
                    "visibility_level": "published",
                    "moderation_stage": "approved",
                    "name_translations": {
                      "en": "Other project with previously existing terms for category and status",
                      "es": "Otro proyecto con términos existentes previamente para categoría y estado"
                    },
                    "category_external_id": "2",
                    "status_external_id": "3",
                    "progress": 99.0
                  }
                ]
              }
            }
          }
        end

        def valid_params_without_vocabularies_and_projects
          {
            data: {
              type: "gobierto_plans-plans",
              attributes: {
                "slug": "new-plan-from-api",
                "title_translations": {
                  "en": "New plan from API",
                  "es": "Nuevo plan desde la API"
                },
                "introduction_translations": {
                  "en": "New plan from API (description)",
                  "es": "Nuevo plan desde la API (descripción)"
                },
                "configuration_data": {
                  "level0": {
                    "one": {
                      "en": "axe",
                      "es": "eje"
                    },
                    "other": {
                      "en": "axes",
                      "es": "ejes"
                    }
                  },
                  "level1": {
                    "one": {
                      "en": "actuation line",
                      "es": "línea de actuación"
                    },
                    "other": {
                      "en": "actuation lines",
                      "es": "líneas de actuación"
                    }
                  },
                  "level0_options": [],
                  "show_table_header": false,
                  "open_node": false
                },
                "year": 2025,
                "visibility_level": "published",
                "css": ".gobierto_planification section.level_0 .cat_1 {
                          background-color: rgba(0, 191, 255, 0.95);
                        }",
                "footer_translations": { "en": "Footer", "es": "Pie" }
              }
            }
          }
        end

        def valid_params
          {
            data: {
              type: "gobierto_plans-plans",
              attributes: {
                "slug": "new-plan-from-api",
                "title_translations": {
                  "en": "New plan from API",
                  "es": "Nuevo plan desde la API"
                },
                "introduction_translations": {
                  "en": "New plan from API (description)",
                  "es": "Nuevo plan desde la API (descripción)"
                },
                "configuration_data": {
                  "level0": {
                    "one": {
                      "en": "axe",
                      "es": "eje"
                    },
                    "other": {
                      "en": "axes",
                      "es": "ejes"
                    }
                  },
                  "level1": {
                    "one": {
                      "en": "actuation line",
                      "es": "línea de actuación"
                    },
                    "other": {
                      "en": "actuation lines",
                      "es": "líneas de actuación"
                    }
                  },
                  "level0_options": [],
                  "show_table_header": false,
                  "open_node": false
                },
                "year": 2025,
                "visibility_level": "published",
                "css": ".gobierto_planification section.level_0 .cat_1 {
                          background-color: rgba(0, 191, 255, 0.95);
                        }",
                "footer_translations": { "en": "Footer", "es": "Pie" },
                "categories_vocabulary_terms": [
                  {
                    "name_translations": {
                      "en": "New term 1",
                      "es": "Nuevo termino 1"
                    },
                    "description_translations": {
                      "en": "New term 1 desc",
                      "es": "Nuevo termino 1 desc"
                    },
                    "slug": "term-slug",
                    "position": 0,
                    "level": 0,
                    "parent_id": nil,
                    "external_id": "E0001"
                  },
                  {
                    "name_translations": {
                      "en": "New term 1.1",
                      "es": "Nuevo termino 1.1"
                    },
                    "description_translations": {
                      "en": "New term 1.1 desc",
                      "es": "Nuevo termino 1.1 desc"
                    },
                    "slug": "term-slug-11",
                    "position": 0,
                    "level": 1,
                    "parent_id": "E0001",
                    "external_id": "E0001.1"
                  },
                  {
                    "name_translations": {
                      "en": "New term 1.2",
                      "es": "Nuevo termino 1.2"
                    },
                    "description_translations": {
                      "en": "New term 1.2 desc",
                      "es": "Nuevo termino 1.2 desc"
                    },
                    "slug": "term-slug-12",
                    "position": 0,
                    "level": 1,
                    "parent_id": "E0001",
                    "external_id": "E0001.2"
                  }
                ],
                "statuses_vocabulary_terms": [
                  {
                    "name_translations": {
                      "en": "Status A",
                      "es": "Status A"
                    },
                    "description_translations": {
                      "en": "This is the A status",
                      "es": "This is the A status"
                    },
                    "slug": "status-a-slug",
                    "position": 0,
                    "level": 0,
                    "parent_id": nil,
                    "external_id": "ST000A"
                  },
                  {
                    "name_translations": {
                      "en": "Status B",
                      "es": "Status B"
                    },
                    "description_translations": {
                      "en": "This is the B status",
                      "es": "This is the B status"
                    },
                    "slug": "status-b-slug",
                    "position": 0,
                    "level": 0,
                    "parent_id": nil,
                    "external_id": "ST000B"
                  },
                  {
                    "name_translations": {
                      "en": "Status C",
                      "es": "Status C"
                    },
                    "description_translations": {
                      "en": "This is the C status",
                      "es": "This is the C status"
                    },
                    "slug": "status-c-slug",
                    "position": 0,
                    "level": 0,
                    "parent_id": nil,
                    "external_id": "ST000C"
                  }
                ],
                "projects": [
                  {
                    "external_id": "PRJ-1",
                    "visibility_level": "published",
                    "moderation_stage": "approved",
                    "name_translations": {
                      "en": "The very first project",
                      "es": "El primerísimo proyecto"
                    },
                    "category_external_id": "E0001.1",
                    "status_external_id": "ST000B",
                    "progress": 100.0
                  },
                  {
                    "external_id": "PRJ-2",
                    "visibility_level": "published",
                    "moderation_stage": "approved",
                    "name_translations": {
                      "en": "Another project",
                      "es": "Otro proyecto"
                    },
                    "category_external_id": "E0001.1",
                    "status_external_id": "ST000A",
                    "progress": 80.0
                  },
                  {
                    "external_id": "PRJ-3",
                    "visibility_level": "published",
                    "moderation_stage": "approved",
                    "name_translations": {
                      "en": "Unfinished project",
                      "es": "Poyecto inacabado"
                    },
                    "category_external_id": "E0001.2",
                    "status_external_id": "ST000B",
                    "progress": 12.0
                  },
                  {
                    "external_id": "PRJ-4",
                    "visibility_level": "published",
                    "moderation_stage": "approved",
                    "name_translations": {
                      "en": "Not started project",
                      "es": "Proyecto sin empezar"
                    },
                    "category_external_id": "E0001.2",
                    "status_external_id": "ST000C",
                    "progress": 0.0
                  }
                ]
              }
            }
          }
        end

        def update_valid_params
          {
            data: {
              attributes: {
                projects: [
                  {
                    "external_id": "1",
                    "visibility_level": "published",
                      "moderation_stage": "approved",
                      "name_translations": {
                        "en": "Scholarships in kindergartens UPDATED",
                        "es": "Becas en guarderías ACTUALIZADAS"
                      },
                      "category_external_id": "4",
                      "status_external_id": "2",
                      "progress": 25.0
                  },
                  {
                    "external_id": "2",
                    "visibility_level": "published",
                    "moderation_stage": "approved",
                    "name_translations": {
                      "en": "Publish political agendas UPDATED",
                      "es": "Publicar agendas políticas ACTUALIZADAS"
                    },
                    "category_external_id": "3",
                    "status_external_id": "1",
                    "progress": 0.0
                  },
                  {
                    "external_id": "new",
                    "visibility_level": "published",
                    "moderation_stage": "approved",
                    "name_translations": {
                      "en": "New project",
                      "es": "Nuevo proyecto"
                    },
                    "category_external_id": "4",
                    "status_external_id": "2",
                    "progress": 50.0
                  }
                ]
              }
            }
          }
        end

        def check_unauthorized
          with(site:) do
            yield

            assert_response :unauthorized
          end
        end

        # GET /api/v1/plans
        # GET /api/v1/plans.json
        def test_index
          with(site:) do
            get gobierto_plans_api_v1_plans_path, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            assert_equal plans_count, response_data["data"].count
            plans_titles = response_data["data"].map { |item| item.dig("attributes", "title") }
            assert_includes plans_titles, plan.title
            assert_includes plans_titles, other_plan.title
            refute_includes plans_titles, draft_plan.title
          end
        end

        # GET /api/v1/plans/1
        # GET /api/v1/plans/1.json
        def test_show
          with(site:) do
            get gobierto_plans_api_v1_plan_path(plan)

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"

            resource_data = response_data["data"]
            assert_equal plan.id.to_s, resource_data["id"]
            assert_equal "gobierto_plans-plans", resource_data["type"]

            attributes = public_attributes_data(plan)

            attributes.each do |attribute, value|
              assert resource_data["attributes"].has_key? attribute
              assert_equal value, resource_data["attributes"][attribute]
            end

            # vocabularies
            categories_terms = plan.categories.map(&:name)
            statuses_terms = plan.statuses_vocabulary.terms.map(&:name)

            assert resource_data["attributes"].has_key? "categories_vocabulary_terms"
            resource_data["attributes"]["categories_vocabulary_terms"].each do |term|
              assert_includes categories_terms, term["attributes"]["name"]
            end

            assert resource_data["attributes"].has_key? "statuses_vocabulary_terms"
            resource_data["attributes"]["statuses_vocabulary_terms"].each do |term|
              assert_includes statuses_terms, term["attributes"]["name"]
            end

            #projects
            refute resource_data["attributes"].has_key? "projects"
          end
        end

        # GET /api/v1/plans/1/admin
        # GET /api/v1/plans/1/admin.json
        def test_admin_show_without_token
          check_unauthorized { get admin_gobierto_plans_api_v1_plan_path(plan), as: :json }
        end

        # GET /api/v1/plans/1/admin
        # GET /api/v1/plans/1/admin.json
        def test_admin_show_with_user_token
          check_unauthorized { get admin_gobierto_plans_api_v1_plan_path(plan), headers: { Authorization: user_token }, as: :json }
        end

        # GET /api/v1/plans/1/admin
        # GET /api/v1/plans/1/admin.json
        def test_admin_show_with_admin_token
          with(site:) do
            get admin_gobierto_plans_api_v1_plan_path(other_plan), headers: { Authorization: admin_token }, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"

            resource_data = response_data["data"]
            assert_equal other_plan.id.to_s, resource_data["id"]
            assert_equal "gobierto_plans-plans", resource_data["type"]

            attributes = admin_attributes_data(other_plan)

            attributes.each do |attribute, value|
              assert resource_data["attributes"].has_key? attribute
              assert_equal value, resource_data["attributes"][attribute]
            end

            # vocabularies
            categories_terms = other_plan.categories.map(&:name)
            statuses_terms = other_plan.statuses_vocabulary.terms.map(&:name)

            assert resource_data["attributes"].has_key? "categories_vocabulary_terms"
            resource_data["attributes"]["categories_vocabulary_terms"].each do |term|
              assert_includes categories_terms, term["attributes"]["name"]
            end

            assert resource_data["attributes"].has_key? "statuses_vocabulary_terms"
            resource_data["attributes"]["statuses_vocabulary_terms"].each do |term|
              assert_includes statuses_terms, term["attributes"]["name"]
            end

            #projects
            assert resource_data["attributes"].has_key? "projects"
            assert_equal other_plan.nodes.count, resource_data["attributes"]["projects"].count
            [other_plan_project, other_plan_draft_project].each do |p|
              assert resource_data["attributes"]["projects"].any? { |data| data["id"] == p.id && data["external_id"] == p.external_id }
            end
          end
        end

        # POST /api/v1/plans/plan-type-slug
        # POST /api/v1/plans/plan-type-slug.json
        def test_create_without_token
          check_unauthorized { post gobierto_plans_api_v1_plan_type_plans_path(plan_type), as: :json, params: valid_params }
        end

        # POST /api/v1/plans/plan-type-slug
        # POST /api/v1/plans/plan-type-slug.json
        def test_create_with_user_token
          check_unauthorized { post gobierto_plans_api_v1_plan_type_plans_path(plan_type), headers: { Authorization: user_token }, as: :json, params: valid_params }
        end

        # POST /api/v1/plans/plan-type-slug
        # POST /api/v1/plans/plan-type-slug.json
        def test_create_with_admin_token
          with(site:) do
            assert_difference(
              "GobiertoPlans::Plan.count" => 1,
              "GobiertoPlans::Node.count" => 4,
              "GobiertoCommon::Vocabulary.count" => 2,
              "GobiertoCommon::Term.count" => 6
            ) do
              post gobierto_plans_api_v1_plan_type_plans_path(plan_type.slug), headers: { Authorization: admin_token }, as: :json, params: valid_params

              assert_response :created
              response_data = response.parsed_body

              new_plan = GobiertoPlans::Plan.last
              categories_vocabulary = new_plan.categories_vocabulary
              statuses_vocabulary = new_plan.statuses_vocabulary

              attributes = admin_attributes_data(new_plan)
              resource_data = response_data["data"]

              attributes.each do |attribute, value|
                assert resource_data["attributes"].has_key? attribute
                assert_equal value, resource_data["attributes"][attribute]
              end

              # vocabularies
              categories_terms = categories_vocabulary.terms.map(&:name)
              statuses_terms = statuses_vocabulary.terms.map(&:name)

              assert resource_data["attributes"].has_key? "categories_vocabulary_terms"
              resource_data["attributes"]["categories_vocabulary_terms"].each do |term|
                assert_includes categories_terms, term["attributes"]["name"]
              end

              assert resource_data["attributes"].has_key? "statuses_vocabulary_terms"
              resource_data["attributes"]["statuses_vocabulary_terms"].each do |term|
                assert_includes statuses_terms, term["attributes"]["name"]
              end

              #projects
              assert resource_data["attributes"].has_key? "projects"
              assert_equal new_plan.nodes.count, resource_data["attributes"]["projects"].count

              valid_params[:data][:attributes][:projects].each do |project_data|
                project = new_plan.nodes.find_by_external_id(project_data[:external_id])

                assert_equal project_data[:name_translations], project.name_translations.symbolize_keys
                assert_equal project_data[:category_external_id], project.categories.first.external_id
                assert_equal project_data[:status_external_id], project.status.external_id
                assert_equal project_data[:progress], project.progress
                assert_equal project_data[:moderation_stage], project.moderation_stage
                assert_equal project_data[:visibility_level], project.visibility_level
              end
            end
          end
        end

        # POST /api/v1/plans/plan-type-slug
        # POST /api/v1/plans/plan-type-slug.json
        def test_create_with_admin_token_without_vocabularies_and_projects
          with(site:) do
            assert_difference(
              "GobiertoPlans::Plan.count" => 1,
              "GobiertoPlans::Node.count" => 0,
              "GobiertoCommon::Vocabulary.count" => 2,
              "GobiertoCommon::Term.count" => 0
            ) do
              post gobierto_plans_api_v1_plan_type_plans_path(plan_type.slug), headers: { Authorization: admin_token }, as: :json, params: valid_params_without_vocabularies_and_projects

              assert_response :created
              response_data = response.parsed_body

              new_plan = GobiertoPlans::Plan.last
              categories_vocabulary = new_plan.categories_vocabulary
              statuses_vocabulary = new_plan.statuses_vocabulary

              attributes = admin_attributes_data(new_plan)
              resource_data = response_data["data"]

              attributes.each do |attribute, value|
                assert resource_data["attributes"].has_key? attribute
                assert_equal value, resource_data["attributes"][attribute]
              end

              # vocabularies
              assert resource_data["attributes"].has_key? "categories_vocabulary_terms"
              assert resource_data["attributes"]["categories_vocabulary_terms"].blank?

              assert resource_data["attributes"].has_key? "statuses_vocabulary_terms"
              assert resource_data["attributes"]["statuses_vocabulary_terms"].blank?

              #projects
              assert resource_data["attributes"].has_key? "projects"
              assert resource_data["attributes"]["projects"].blank?
            end
          end
        end

        def test_create_with_admin_token_with_existing_vocabularies
          with(site:) do
            assert_difference(
              "GobiertoPlans::Plan.count" => 1,
              "GobiertoPlans::Node.count" => 0,
              "GobiertoCommon::Vocabulary.count" => 0,
              "GobiertoCommon::Term.count" => 0
            ) do
              post gobierto_plans_api_v1_plan_type_plans_path(plan_type.slug), headers: { Authorization: admin_token }, as: :json, params: valid_params_with_existing_vocabularies

              assert_response :created
              response_data = response.parsed_body

              new_plan = GobiertoPlans::Plan.last
              categories_vocabulary = new_plan.categories_vocabulary
              statuses_vocabulary = new_plan.statuses_vocabulary

              attributes = admin_attributes_data(new_plan)
              resource_data = response_data["data"]

              attributes.each do |attribute, value|
                assert resource_data["attributes"].has_key? attribute
                assert_equal value, resource_data["attributes"][attribute]
              end

              # vocabularies
              assert resource_data["attributes"].has_key? "categories_vocabulary_terms"
              # assert resource_data["attributes"]["categories_vocabulary_terms"].blank?

              assert resource_data["attributes"].has_key? "statuses_vocabulary_terms"
              # assert resource_data["attributes"]["statuses_vocabulary_terms"].blank?

              #projects
              assert resource_data["attributes"].has_key? "projects"
              assert resource_data["attributes"]["projects"].blank?
            end
          end
        end

        def test_create_with_admin_token_with_existing_vocabularies_and_new_items
          with(site:) do
            assert_difference(
              "GobiertoPlans::Plan.count" => 1,
              "GobiertoPlans::Node.count" => 2,
              "GobiertoCommon::Vocabulary.count" => 0,
              "GobiertoCommon::Term.count" => 2
            ) do
              post gobierto_plans_api_v1_plan_type_plans_path(plan_type.slug), headers: { Authorization: admin_token }, as: :json, params: valid_params_with_existing_vocabularies_and_new_items

              assert_response :created
              response_data = response.parsed_body

              new_plan = GobiertoPlans::Plan.last
              categories_vocabulary = new_plan.categories_vocabulary
              statuses_vocabulary = new_plan.statuses_vocabulary

              attributes = admin_attributes_data(new_plan)
              resource_data = response_data["data"]

              attributes.each do |attribute, value|
                assert resource_data["attributes"].has_key? attribute
                assert_equal value, resource_data["attributes"][attribute]
              end

              # vocabularies
              assert resource_data["attributes"].has_key? "categories_vocabulary_terms"
              # assert resource_data["attributes"]["categories_vocabulary_terms"].blank?

              assert resource_data["attributes"].has_key? "statuses_vocabulary_terms"
              # assert resource_data["attributes"]["statuses_vocabulary_terms"].blank?

              #projects
              assert resource_data["attributes"].has_key? "projects"
              assert_equal new_plan.nodes.count, resource_data["attributes"]["projects"].count

              valid_params_with_existing_vocabularies_and_new_items[:data][:attributes][:projects].each do |project_data|
                project = new_plan.nodes.find_by_external_id(project_data[:external_id])

                assert_equal project_data[:name_translations], project.name_translations.symbolize_keys
                assert_equal project_data[:category_external_id], project.categories.first.external_id
                assert_equal project_data[:status_external_id], project.status.external_id
                assert_equal project_data[:progress], project.progress
                assert_equal project_data[:moderation_stage], project.moderation_stage
                assert_equal project_data[:visibility_level], project.visibility_level
              end
            end
          end
        end


        # PUT /api/v1/plans/1
        # PUT /api/v1/plans/1.json
        def test_update_without_token
          check_unauthorized { put gobierto_plans_api_v1_plan_path(other_plan), as: :json, params: update_valid_params }
        end

        # PUT /api/v1/plans/1
        # PUT /api/v1/plans/1.json
        def test_update_with_user_token
          check_unauthorized { put gobierto_plans_api_v1_plan_path(other_plan), headers: { Authorization: user_token }, as: :json, params: update_valid_params }
        end

        # PUT /api/v1/plans/1
        # PUT /api/v1/plans/1.json
        def test_update_with_admin_token
          with(site:) do
            assert_no_difference(
              "GobiertoPlans::Plan.count" => 0,
              "GobiertoPlans::Node.count" => 1,
              "GobiertoCommon::Vocabulary.count" => 0,
              "GobiertoCommon::Term.count" => 0
            ) do
              put gobierto_plans_api_v1_plan_path(other_plan), headers: { Authorization: admin_token }, as: :json, params: update_valid_params

              assert_response :success
              response_data = response.parsed_body

              attributes = admin_attributes_data(other_plan.reload)
              resource_data = response_data["data"]

              attributes.each do |attribute, value|
                assert resource_data["attributes"].has_key? attribute
                assert_equal value, resource_data["attributes"][attribute]
              end

              # vocabularies
              categories_terms = other_plan.categories.map(&:name)
              statuses_terms = other_plan.statuses_vocabulary.terms.map(&:name)

              assert resource_data["attributes"].has_key? "categories_vocabulary_terms"
              resource_data["attributes"]["categories_vocabulary_terms"].each do |term|
                assert_includes categories_terms, term["attributes"]["name"]
              end

              assert resource_data["attributes"].has_key? "statuses_vocabulary_terms"
              resource_data["attributes"]["statuses_vocabulary_terms"].each do |term|
                assert_includes statuses_terms, term["attributes"]["name"]
              end

              #projects
              assert resource_data["attributes"].has_key? "projects"
              assert_equal 3, resource_data["attributes"]["projects"].count

              update_valid_params[:data][:attributes][:projects].each do |project_data|
                project = other_plan.nodes.find_by_external_id(project_data[:external_id])

                assert_equal project_data[:name_translations], project.name_translations.symbolize_keys
                assert_equal project_data[:category_external_id], project.categories.first.external_id
                assert_equal project_data[:status_external_id], project.status.external_id
                assert_equal project_data[:progress], project.progress
                assert_equal project_data[:moderation_stage], project.moderation_stage
                assert_equal project_data[:visibility_level], project.visibility_level
              end
            end
          end
        end
      end
    end
  end
end
