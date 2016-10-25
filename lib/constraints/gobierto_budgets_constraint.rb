class GobiertoBudgetsConstraint
  def initialize
  end

  def matches?(request)
    full_domain = request.env['HTTP_HOST'] || request.env['SERVER_NAME'] || request.env['SERVER_ADDR']

    full_domain.split(':').first == 'presupuestos.' + Settings.gobierto_host
  end
end
