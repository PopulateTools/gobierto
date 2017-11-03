class GobiertoBudgets::FeedbackController < GobiertoBudgets::ApplicationController
  respond_to :js

  before_action :set_params

  def step1
  end

  def step2
    if @answer1 == 1
      reply = GobiertoBudgets::BudgetLineFeedback.create! site: current_site, year: @year, budget_line_id: @id, answer1: @answer1
      @datum = GobiertoBudgets::BudgetLineFeedback.stats(site: current_site, id: reply.budget_line_id, year: reply.year, answer1: reply.answer1)
    end
  end

  def step3
    @reply = GobiertoBudgets::BudgetLineFeedback.create! site: current_site, year: @year, budget_line_id: @id, answer1: @answer1, answer2: @answer2
  end

  def follow
    if params[:email].blank?
      @success = false
      return false
    end

    if params[:ask_for_feedback]
      budget_line = GobiertoBudgets::BudgetLinePresenter.load(params[:id], current_site)
      budget_line_name = budget_line ? budget_line.name : nil
      year = budget_line ? budget_line.year : Date.today.year
      GobiertoBudgets::FeedbackMailer.new_feedback_request({
        to: gobierto_budgets_feedback_emails,
        budget_line_name: budget_line_name,
        year: year,
        person_email: params[:email],
        site: current_site
      }).deliver_later
    end
    user_subscription_form = User::SubscriptionForm.new site: current_site, creation_ip: remote_ip, subscribable_type: "Site", subscribable_id: current_site.id, user_email: params[:email]
    user_subscription_form.save
    @success = true
  end

  def load_follow
  end

  private

  def set_params
    @id = params[:id] if params[:id]
    @year = params[:year] if params[:year]
    @answer1 = params[:answer1].to_i if params[:answer1]
    @answer2 = params[:answer2].to_i if params[:answer2]
  end
end
