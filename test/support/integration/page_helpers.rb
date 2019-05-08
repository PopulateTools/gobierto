# frozen_string_literal: true

module Integration
  module PageHelpers
    def scroll_to_top
      page.driver.scroll_to(0, 0)
    end

    def switch_locale(new_locale)
      if javascript_driver?
        page.find("[data-toggle-edit-locale='#{new_locale.downcase}']", visible: false).execute_script("this.click()")
      else
        begin
          within(".language_selector") { click_link new_locale.upcase }
        rescue Capybara::ElementNotFound
          click_link new_locale.upcase
        end
      end
    end
  end
end
