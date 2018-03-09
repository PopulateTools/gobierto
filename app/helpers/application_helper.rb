# frozen_string_literal: true

module ApplicationHelper
  def render_if_exists(partial_path, partial_params = {}, format = "html.erb")
    partial_path_name = Pathname.new(partial_path)
    partial_file_name = "#{partial_path_name.dirname}/_#{partial_path_name.basename}.#{format}"

    render(partial_path, partial_params) if lookup_context.exists?(partial_file_name)
  end

  # Example: translate_enum_value(GobiertoParticipation::ProcessStage, :stage_type, :information)
  def translate_enum_value(object, enum_name, enum_value_name)
    I18n.t("activerecord.attributes.#{object.model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value_name}")
  end

  def localized_enum(class_name, enum_name)
    return {} unless class_name.respond_to?(enum_name.to_s.pluralize)

    class_name.send(enum_name.to_s.pluralize).reduce({}) do |enum_options, (key, _)|
      enum_options.merge!(
        I18n.t("activerecord.attributes.#{class_name.model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{key}", default: key.capitalize) => key
      )
    end
  end

  def privacy_policy_page_link
    if current_site && current_site.configuration.privacy_page?
      link_to t("layouts.accept_privacy_policy_signup"), gobierto_cms_page_or_news_path(current_site.configuration.privacy_page)
    end
  end

  def tab_attributes(condition)
    { role: "tab", "tabindex" => condition ? 0 : -1, "aria-selected" => condition }
  end

  def show_social_links?
    !params[:controller].include?("user/")
  end

  def full_layout?
    controller_name == "contribution_containers" && action_name == "show"
  end

  def filetype_icon(attachment)
    extension = if attachment.class == String
                  attachment.split(".").last
                else
                  attachment.extension
                end

    fontawesome_filetype = if ::GobiertoAttachments::Attachment.extension_fontawesome_matching.has_key?(extension.to_sym)
                             "-" + ::GobiertoAttachments::Attachment.extension_fontawesome_matching[extension.to_sym]
                           else
                             ""
                           end
    html = "<i class='fa fa-file" + fontawesome_filetype + "-o'></i>"
    html.html_safe
  end

  def current_parameters_with_year(year)
    params.except(:host, :port, :protocol).merge(year: year).permit!
  end

  def next_poll(poll_id = nil)
    poll = GobiertoParticipation::Poll.by_site(current_site).find(poll_id) if poll_id
    answerable_polls = GobiertoParticipation::Poll.by_site(current_site).answerable.order(ends_at: :asc)
    answerable_polls_by_user = answerable_polls.detect { |p| p.answerable_by?(current_user) } if current_user

    if current_user
      if poll && poll.answerable_by?(current_user)
        poll
      elsif answerable_polls_by_user
        answerable_polls_by_user
      end
    else
      answerable_polls.first
    end
  end

  def content_for_if(name, condition, &block)
    if condition
      content_for(name, &block)
    end
    yield
  end

  def attribute_indication(model, attribute)
    validates_presence = validated_attrs_for(model, :presence).include?(attribute)
    validates_length = validated_attrs_for(model, :length).include?(attribute)

    if validates_presence || validates_length
      content_tag(:span, class: 'indication') do
        if validates_presence && validates_length
          I18n.t("views.forms.required_and_max_characters", length: get_maxlength(model, attribute))
        elsif validates_presence
          I18n.t("views.forms.required")
        elsif validates_length
          I18n.t("views.forms.max_characters", length: get_maxlength(model, attribute))
        end
      end
    end
  end

  def validated_attrs_for(model, validation)
    if validation.is_a?(String) || validation.is_a?(Symbol)
      klass = 'ActiveRecord::Validations::' \
              "#{validation.to_s.camelize}Validator"
      validation = klass.constantize
    end
    model.validators
         .select { |v| v.is_a?(validation) }
         .map(&:attributes)
         .flatten
  end

  def get_maxlength(model, attribute)
    model.validators_on(attribute)
         .detect { |v| v.is_a?(ActiveModel::Validations::LengthValidator) }
         .options[:maximum]
  end
end
