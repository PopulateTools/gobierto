# frozen_string_literal: true

class Sidekiq::EventBouncer < Sidekiq::Bouncer

  # - Overwriting this or the config will be missing in the original class methods
  class << self
    def config
      Sidekiq::Bouncer.config
    end
  end

  # - Replacing perform_at for perform_later + set(wait_until:)
  # - perform_at does not exists in Rails jobs (just sidekiq workers)
  def debounce(*params)
    # Refresh the timestamp in redis with debounce delay added.
    self.class.config.redis.set(key(params), now + @delay)

    # Schedule the job with not only debounce delay added, but also BUFFER.
    # BUFFER helps prevent race condition between this line and the one above.
    @klass.set(wait_until: now + @delay + BUFFER).perform_later(*params)
  end

  private

  # - Replacing this because the search params might be different,
  # so checking only user, controller and action is enough
  def key(params)
    user_id, _organization_id, properties = *params
    controller = properties[:controller]
    action = properties[:action]

    keyable_params = [user_id, controller, action]

    "#{@klass}:#{keyable_params.join(",")}"
  end

end
