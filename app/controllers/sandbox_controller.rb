class SandboxController < ApplicationController
  before_action :set_working_variables
  layout :set_layout

  helper_method(
    :current_site,
    :user_signed_in?,
    :current_user,
    :managed_sites,
    :can_manage_sites?,
    :managing_site?,
    :admin_signed_in?,
    :current_admin
  )

  def index
    @templates = Dir.glob(Rails.root.join('app/views/sandbox/*.html.erb').to_s).sort.map do |filename|
      filename = File.basename(filename, File.extname(filename))
      filename unless filename.starts_with?('_') || filename == 'index.html'
    end.compact
  end

  def show
    @sub_section = sub_section
    if params[:template].index('.') # CVE-2014-0130
      redirect_to action: :index
    elsif lookup_context.exists?("sandbox/#{params[:template]}")
      if params[:template] == "index"
        redirect_to action: :index
      else
        render "sandbox/#{params[:template]}"
      end
    elsif lookup_context.exists?("sandbox/#{params[:template]}/index")
      render "sandbox/#{params[:template]}/index"
    else
      redirect_to action: :index
    end
  end

  private

  def sub_section
    if params[:template].split("_").second
      return params[:template].split("_").first + '_' + params[:template].split("_").second
    elsif params[:template].split("_").first
      return params[:template].split("_").first
    end
  end

  def set_layout
    return "sandbox/application" unless params[:template]

    case params[:template].split("_").first
    when "admin"        then "sandbox/gobierto_admin/application"
    when "budget"       then "sandbox/gobierto_budgets/application"
    else "sandbox/application"
    end
  end

  def set_working_variables
    @place = current_site.place
    @year = GobiertoBudgets::SearchEngineConfiguration::Year.last
  end

  def current_site
    SiteDecorator.new(Site.first)
  end

  def user_signed_in?
    true
  end

  def admin_authorized?
    true
  end

  def current_user
    User.first
  end

  def managed_sites
    [current_site]
  end

  def can_manage_sites?
    true
  end

  def managing_site?
    true
  end

  def admin_signed_in?
    true
  end

  def current_admin
    GobiertoAdmin::Admin.first
  end
end
