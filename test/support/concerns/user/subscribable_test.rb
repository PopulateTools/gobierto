# frozen_string_literal: true

module User::SubscribableTest
  class User::SubscribableClass
    include Subscribable
    attr_accessor :title, :name
  end

  def test_class_subscribable_label
    assert_equal(
      subscribable.model_name.human.pluralize,
      subscribable.class.subscribable_label
    )
  end

  def test_subscribable_label
    subscribable = User::SubscribableClass.new
    subscribable.title = "foo"
    subscribable.name = "bar"

    assert_equal "foo", subscribable.subscribable_label

    subscribable.title = nil
    subscribable.name = "bar"

    assert_equal "bar", subscribable.subscribable_label
  end

  def test_to_path
    subscribable_identifier = subscribable.respond_to?(:slug) ? subscribable.slug : subscribable.to_param

    assert_not_nil subscribable.to_path
    assert_includes subscribable.to_path, subscribable_identifier
  end

  def test_to_url
    subscribable_identifier = subscribable.respond_to?(:slug) ? subscribable.slug : subscribable.to_param

    assert_not_nil subscribable.to_url
    assert_includes subscribable.to_url, subscribable_identifier
    assert_includes subscribable.to_url, sites(:madrid).domain
    assert_includes subscribable.to_url(host: "site.gobierto.test"), "site.gobierto.test"
  end
end
