class ActivityDecorator < BaseDecorator
  def initialize(activity)
    @object = activity
  end

  def subject_name
    fetch_relation(:subject)
  end

  def author_name
    fetch_relation(:author)
  end

  def recipient_name
    fetch_relation(:recipient)
  end

  def translated_action
    object_module = @object.action.split('.').first

    I18n.t("#{object_module}.events.#{@object.action.tr('.', '_')}", subject_name: subject_name)
  end

  def active?
    @object.subject.present? && @object.subject.respond_to?(:active?) && @object.subject.active?
  end

  private

  def fetch_relation(relation_name)
    if object.send(relation_name).present?
      object.send(relation_name).try(:name) || object.send(relation_name).try(:title)
    else
      if object.send("#{relation_name}_type").present?
        "(deleted) #{object.send("#{relation_name}_type")} - #{object.send("#{relation_name}_id")}"
      else
        "-"
      end
    end
  end
end
