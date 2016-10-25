module AutocompleteHelpers
  def fill_autocomplete(css_id, page, options = {})
    find("#{css_id}").native.send_keys options[:with]
    page.execute_script %{ $('#{css_id}').trigger('focus') }
    page.execute_script %{ $('#{css_id}').trigger('keydown') }
    selector = %{div.autocomplete-suggestion:contains("#{options[:select]}"):eq(0)}
    expect(page).to have_selector('div.autocomplete-suggestion')
    page.execute_script %{ $('#{selector}').trigger('mouseenter').click() }
  end
end

RSpec.configure do |c|
  c.include AutocompleteHelpers
end
