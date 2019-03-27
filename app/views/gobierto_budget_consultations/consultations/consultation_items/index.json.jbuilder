# frozen_string_literal: true

json.array! @consultation_items do |consultation_item|
  json.id consultation_item.id
  json.hidden false
  json.toggleDesc false
  json.title consultation_item.title
  json.figure budget_amount_to_human(consultation_item.budget_line_amount)
  json.description consultation_item.description
  json.choice nil
  json.block_reduction consultation_item.block_reduction
end
