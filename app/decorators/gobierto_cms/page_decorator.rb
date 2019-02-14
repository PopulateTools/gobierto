module GobiertoCms
  class PageDecorator < BaseDecorator
    include ActionView::Helpers::TextHelper

    def initialize(page, context = nil, item_type = nil)
      @object = page
      @context = context || page.collection.container_type
      @item_type = item_type || page.collection.item_type
    end

    attr_reader :context

    def template
      case context
        when "GobiertoParticipation"
          "gobierto_participation/pages/templates/#{sub_template}"
        when "GobiertoParticipation::Process"
          "gobierto_participation/processes/pages/templates/#{sub_template}"
        else
          default_template
      end
    end

    def main_image
      object.attachments.each do |attachment|
        return attachment.url if attachment.content_type.start_with?("image/")
      end
      nil
    end

    def summary(length = 100)
      truncate(strip_tags(body), length: length)
    end

    private

    attr_reader :object, :item_type

    def sub_template
      item_type.split('::').last.downcase
    end

    def default_template
      "gobierto_cms/pages/templates/#{@object.template || sub_template}"
    end

  end
end
