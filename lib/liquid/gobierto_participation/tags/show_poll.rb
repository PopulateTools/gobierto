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
    current_site = context.environments.second["current_site"]
    current_user = context.environments.first["current_user"]

    poll = next_poll(current_site, current_user, @poll_id)

    context.registers[:controller].dup.render(partial: "shared/polls", locals: { poll: poll })
  end

  def next_poll(current_site, current_user, poll_id = nil)
    poll = GobiertoParticipation::Poll.by_site(current_site).find(poll_id) if poll_id
    answerable_polls = GobiertoParticipation::Poll.by_site(current_site).answerable.order(ends_at: :asc)
    answerable_polls_by_user = answerable_polls.detect { |p| p.answerable_by?(current_user) } if current_user

    if current_user
      if poll && poll.answerable_by?(current_user)
        poll
      elsif answerable_polls_by_user
        answerable_polls_by_user
      end
    else
      answerable_polls.first
    end
  rescue ActiveRecord::RecordNotFound
    return ""
  end
end

Liquid::Template.register_tag("show_poll", ShowPoll)
