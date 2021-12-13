Rails.application.configure do
  exceptions = %w(controller action format id)

  config.lograge.base_controller_class = ['ActionController::API', 'ActionController::Base']
  config.lograge.custom_options = lambda do |event|
    {
      host: event.payload[:host],
      rails_env: Rails.env,

      process_id: Process.pid,
      request_id: event.payload[:headers]['action_dispatch.request_id'],
      request_time: Time.now,

      remote_ip: event.payload[:remote_ip],
      ip: event.payload[:ip],
      x_forwarded_for: event.payload[:x_forwarded_for],

      params: event.payload[:params].except(*exceptions).to_json,

      exception: event.payload[:exception]&.first,
      exception_message: "#{event.payload[:exception]&.last}",
      exception_backtrace: event.payload[:exception_object]&.backtrace&.join(",")
    }.compact
  end
end
