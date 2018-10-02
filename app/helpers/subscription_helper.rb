# frozen_string_literal: true

module SubscriptionHelper
  def subscription_message(object, action)
    class_name = object.class.name
    item = if class_name == "GobiertoParticipation::Process"
             object.process_type
           elsif class_name == "GobiertoCommon::Term" && (participation_settings = current_site.gobierto_participation_settings).present?
             ["issue", "scope"].find do |type|
               participation_settings.send(:"#{type.tableize}_vocabulary_id").to_i == object.vocabulary_id.to_i
             end
           else
             class_name.demodulize.downcase
           end
    if action == "followed"
      t(".#{item}_followed")
    elsif action == "follow"
      t(".follow_#{item}")
    end
  end
end
