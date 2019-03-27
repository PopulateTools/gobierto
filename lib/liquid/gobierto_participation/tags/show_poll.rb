# frozen_string_literal: true

class ShowPoll < Liquid::Tag
  def initialize(tag_name, poll_id, tokens)
    super
    @poll_id = if poll_id.include?("poll_id")
                 poll_id.match(/(\((.*)\))/)[2].split(": ").last
               else
                 nil
               end
  end

  def render(context)
    current_site = context.registers[:view].current_site
    current_user = context.registers[:view].current_user

    poll = next_poll(current_site, current_user, @poll_id)

    context.registers[:view].dup.render(partial: "shared/polls", locals: { poll: poll })
  end

  def next_poll(current_site, current_user, poll_id = nil)
    poll = GobiertoParticipation::Poll.by_site(current_site).find(poll_id) if poll_id
    answerable_polls = GobiertoParticipation::Poll.by_site(current_site).answerable.order(ends_at: :asc)

    if current_user
      if poll && poll.answerable_by?(current_user)
        poll
      else
        answerable_polls.detect { |p| p.answerable_by?(current_user) }
      end
    else
      poll || answerable_polls.first
    end
  rescue ActiveRecord::RecordNotFound
    ""
  end
end

Liquid::Template.register_tag("show_poll", ShowPoll)
