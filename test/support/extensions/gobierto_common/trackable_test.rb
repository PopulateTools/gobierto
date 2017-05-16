module GobiertoCommon::TrackableTest
  def setup
    super
    @trackable_publisher_spy = Spy.on(Publishers::Trackable, :broadcast_event)
  end

  def test_trackable_extension
    assert subject_class.respond_to?(:notify_changed)
    assert subject_class.respond_to?(:trackable_on)
    refute subject_class.respond_to?(:changed_attributes_to_notify)
  end

  def test_trackable_save
    assert trackable.save
    assert @trackable_publisher_spy.has_been_called?
    assert_trackable_publisher_call
  end

  def test_trackable_notify?
    if trackable.trackable.respond_to?(:active?)
      trackable.trackable.stub(:active?, true) do
        if trackable.trackable.admin_id.present?
          assert trackable.notify?
        end
      end

      trackable.trackable.stub(:active?, false) do
        refute trackable.notify?
      end
    else
      assert trackable.notify?
    end
  end

  private

  def assert_trackable_publisher_call
    first_call = @trackable_publisher_spy.calls.first

    assert_equal Publishers::Trackable, first_call.object
    assert_nil first_call.result
  end
end
