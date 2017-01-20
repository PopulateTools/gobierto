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
    assert_not_nil subscribable.to_path
    assert_includes subscribable.to_path, subscribable.to_param
  end

  def test_to_url
    assert_not_nil subscribable.to_url
    assert_includes subscribable.to_url, subscribable.to_param
    assert_includes subscribable.to_url, ENV["HOST"]
  end
end
