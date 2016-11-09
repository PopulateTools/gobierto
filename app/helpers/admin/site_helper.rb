module Admin::SiteHelper
  def site_visibility_level_badge_for(site)
    case site.visibility_level
    when "draft" then
      content_tag :span do
        capture do
          concat content_tag(:i, nil, class: "fa fa-lock")
          concat "Draft"
        end
      end
    when "active" then
      content_tag :span do
        capture do
          concat content_tag(:i, nil, class: "fa fa-unlock")
          concat "Active"
        end
      end
    end
  end
end
