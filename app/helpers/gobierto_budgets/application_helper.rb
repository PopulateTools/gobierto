module GobiertoBudgets
  module ApplicationHelper

    def external_comparison_link
      municipalities = budgets_comparison_compare_municipalities.map{ |place_id| INE::Places::Place.find(place_id) } + [current_site.place]
      municipalities.compact!
      year = @year || GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.last

      budget_line_path = if params[:id]
        [params[:kind], params[:area_name]].join('/') + "?parent_code=#{params[:id]}"
      else
        "G/economic"
      end

      "https://presupuestos.gobierto.es/compare/#{municipalities.map(&:slug).join(':')}/#{year}/#{budget_line_path}"
    end

    def sign(v1, v2 = nil)
      return 'sign-neutral' if v1.blank? || v2.blank?
      diff = v1 - v2
      if diff > 0
        'sign-up'
      elsif diff < 0
        'sign-down'
      else
        'sign-neutral'
      end
    rescue
      'sign-neutral'
    end

    def format_currency(n, absolute_value = false)
      return nil if n.blank?
      n = n.abs if absolute_value

      if n.abs > 1_000_000
        "#{helpers.number_with_precision(n.to_f / 1_000_000.to_f, precision: 2, strip_insignificant_zeros: true)} M€"
      else
        helpers.number_to_currency(n, precision: 2, strip_insignificant_zeros: true)
      end
    end

    def delta_percentage(current_year_value, old_value, sign = nil)
      value = ((current_year_value.to_f - old_value.to_f)/old_value.to_f) * 100
      formatted_value = number_with_precision(value, precision: 2).to_s + "%"
      if sign
        "#{value > 0 ? '+ ' : ''} #{formatted_value}"
      else
        formatted_value
      end
    end

    def percentage_of_total(value, total)
      percentage_fraction_format(value.to_f / total.to_f)
    end

    def percentage_fraction_format(fraction)
      number_with_precision(fraction * 100, precision: 2) + '%'
    end

    def percentage_format(percentage)
      number_with_precision(percentage, precision: 2) + '%'
    end

    def budget_line_denomination(area_name, code, kind, capped = -1)
      area = BudgetArea.klass_for(area_name)

      if area.all_items[kind][code].nil?
        return " - "
      else
        res = area.all_items[kind][code][0..capped]
        res += "..." if capped < res.length && capped > -1
      end
      res
    end

    def budget_line_description(budget_line)
      kind = budget_line.kind
      code = budget_line.code
      area_name = budget_line.area_name
      description = budget_line.description

      if description != budget_line.name
        return description
      else
        I18n.t(
          'gobierto_budgets.common.budget_line_description_html',
          kind_what: kind_literal(kind),
          description: description.try(:downcase),
          link: link_to(
                  budget_line_denomination(area_name, code[0..-2], kind),
                  gobierto_budgets_budget_line_path(code[0..-2], params[:year], area_name, kind)
                )
        )
      end
    end

    def kind_literal(kind, plural = true)
      if kind == GobiertoBudgets::BudgetLine::INCOME
        plural ? I18n.t('gobierto_budgets.common.incomes') : I18n.t('gobierto_budgets.common.income')
      else
        plural ? I18n.t('gobierto_budgets.common.expenses') : I18n.t('gobierto_budgets.common.expense')
      end
    end

    def planned(kind)
      if kind == GobiertoBudgets::BudgetLine::INCOME
        I18n.t('gobierto_budgets.budget_lines.show.planned')
      else
        I18n.locale == :ca ? I18n.t('gobierto_budgets.budget_lines.show.planned_female') : I18n.t('gobierto_budgets.budget_lines.show.planned')
      end
    end

    def planned_updated(kind)
      if kind == GobiertoBudgets::BudgetLine::INCOME
        I18n.t('gobierto_budgets.budget_lines.show.updated')
      else
        I18n.locale == :ca ? I18n.t('gobierto_budgets.budget_lines.show.updated_female') : I18n.t('gobierto_budgets.budget_lines.show.updated')
      end
    end

    def data_attributes
      attrs = []
      if @place
        attrs << %Q{data-track-url="#{gobierto_budgets_budgets_path(@year || GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.last)}"}
        attrs << %Q{data-place-slug="#{@place.slug}"}
        attrs << %Q{data-place-id="#{@place.id}"}
        attrs << %Q{data-place-name="#{@place.name}"}
      end
      if action_name == 'compare' and controller_name == 'places'
        attrs << %Q{data-comparison-name="#{@places.map{|p| p.name }.join(' + ')}"}
        attrs << %Q{data-comparison-track-url="#{request.path}"}
        attrs << %Q{data-comparison-slug="#{params[:slug_list]}"}
      end
      attrs << %Q{data-year="#{@year || GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.last}"}
      attrs << %Q{data-kind="#{@kind || 'expense'}"}
      attrs << %Q{data-area="#{@area_name || 'economic'}"}
      attrs << %Q{data-action="#{action_name}"}
      attrs.join(' ').html_safe
    end

    def place_name(ine_code)
      INE::Places::Place.find(ine_code).try(:name)
    end

    def parent_code(code)
      if code.present?
        if code.include?('-')
          code.split('-').first
        else
          code[0..-2]
        end
      end
    end

    def bubbles_data_path(site)
      GobiertoBudgets::Data::Bubbles.new(current_site).file_url
    end

    def budget_line_breadcrumb(budget_line, year, kind)
      parent_code_length = if budget_line.parent_code
                             budget_line.parent_code.length
                           else
                             0
                           end
      ([year, kind].concat(parent_code_length.downto(1).map{|i| budget_line.parent_code[0..-i]})).concat([budget_line.code]).join('/')
    end

    def in_elaboration?
      @year && @year > Date.today.year && budgets_elaboration_active?
    end
  end
end
