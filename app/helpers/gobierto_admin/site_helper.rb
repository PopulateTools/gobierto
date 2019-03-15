module GobiertoAdmin
  module SiteHelper
    def site_visibility_level_badge_for(site)
      case site.visibility_level
      when "draft" then
        content_tag :span do
          capture do
            concat content_tag(:i, nil, class: "fas fa-lock")
            concat t("gobierto_admin.sites.form.visibility_level.draft")
          end
        end
      when "active" then
        content_tag :span do
          capture do
            concat content_tag(:i, nil, class: "fas fa-unlock")
            concat t("gobierto_admin.sites.form.visibility_level.active")
          end
        end
      end
    end
  end
end
