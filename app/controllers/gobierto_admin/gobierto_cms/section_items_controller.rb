# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCms
    class SectionItemsController < GobiertoCms::BaseController
      def create
        @section_item_form = SectionItemForm.new(section_id: params[:section_id],
                                                 item_type: "GobiertoCms::Page",
                                                 item_id: params[:page_id],
                                                 parent_id: 0,
                                                 position: ::GobiertoCms::SectionItem.where(section_id: params[:section_id]).without_parent.size,
                                                 level: 0)

        if @section_item_form.save
          track_create_activity

          render(
            json: { id: @section_item_form.section_item.id }
          )
        end
      end

      def show
        @section_item = find_section_item
        render(
          json: { section_item: default_serializer.new(@section_item) }
        )
      end

      def index
        @section = find_section

        section_items = @section.section_items.without_parent.not_archived.sorted.map do |si|
          default_serializer.new(si)
        end

        render(json: { section_items: section_items })
      end

      def destroy
        @section_item = find_section_item

        section_item_brothers = ::GobiertoCms::SectionItem.where("parent_id = ? AND position > ?", @section_item.parent_id, @section_item.position)

        if section_item_brothers
          section_item_brothers.each do |section_item|
            section_item.decrement!(:position)
          end
        end

        if @section_item.destroy
          track_destroy_activity
        end
      end

      def update
        @section_item = find_section_item

        tree = JSON.parse(params['tree'])

        position = 0
        level = 0
        parent_id = 0

        # Recursive method to update the tree
        children(tree, position, level, parent_id)
      end

      private

      def children(nodes, position, level, parent_id)
        nodes.each do |node|
          section_item = ::GobiertoCms::SectionItem.find(node['id'])
          section_item.update(position: position,
                              level: level,
                              parent_id: parent_id)
          unless node['children'].nil?
            children(node['children'], 0, level + 1, node['id'])
          end
          position += 1
        end
      end

      def track_create_activity
        Publishers::GobiertoCmsSectionItemActivity.broadcast_event("section_item_created", default_activity_params.merge(subject: @section_item_form.section_item.item))
      end

      def track_destroy_activity
        Publishers::GobiertoCmsSectionItemActivity.broadcast_event("section_item_deleted", default_activity_params.merge(subject: @section_item.item))
      end

      def default_activity_params
        { ip: remote_ip, author: current_admin, site_id: current_site.id }
      end

      def ignored_issue_attributes
        %w(position created_at updated_at)
      end

      def default_serializer
        ::GobiertoAdmin::GobiertoCms::SectionItemSerializer
      end

      def find_section
        current_site.sections.find(params[:section_id])
      end

      def find_section_item
        ::GobiertoCms::SectionItem.find(params[:id])
      end
    end
  end
end
