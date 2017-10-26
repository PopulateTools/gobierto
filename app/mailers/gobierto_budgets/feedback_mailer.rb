module GobiertoBudgets
  class FeedbackMailer < ApplicationMailer
    def new_feedback_request(args)
      @body = t('.body', budget_line_name: args[:budget_line_name], person_email: args[:person_email], year: args[:year])
      @site = args[:site]
      @site_host = site_host

      mail(
        from: from,
        to: args[:to],
        bcc: 'gobierto_notifications@gobierto.es',
        subject: t('.subject')
      )
    end
  end
end
