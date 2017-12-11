# frozen_string_literal: true

class ShowPoll < Liquid::Tag
  def initialize(tag_name, poll_id, tokens)
    super
    @poll_id = poll_id.match(/(\((.*)\))/)[2].split(": ").last
  end

  def render(context)
    current_site = context.environments.second["current_site"]

    poll = if @poll_id
             GobiertoParticipation::Poll.by_site(current_site).where(id: @poll_id).try(:first)
           else
             next_poll
           end

    if poll
      context.registers[:controller].dup.render(partial: "shared/polls",
                                                locals: { poll_id: poll.id ? @poll_id : nil })
    end
  end
end

Liquid::Template.register_tag("show_poll", ShowPoll)
