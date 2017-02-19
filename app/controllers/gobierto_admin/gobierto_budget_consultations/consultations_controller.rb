module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationsController < BaseController
      before_action { module_enabled!(current_site, "GobiertoBudgetConsultations") }

      def index
        @consultations = current_site.budget_consultations.sorted
      end

      def show
        @consultation = find_consultation
      end

      def new
        @consultation_form = ConsultationForm.new
        @consultation_visibility_levels = get_consultation_visibility_levels
        @opening_date_range_separator = get_opening_date_range_separator
      end

      def edit
        @consultation = find_consultation
        @consultation_form = ConsultationForm.new(
          @consultation.attributes.except(*ignored_consultation_attributes)
        )
        @consultation_visibility_levels = get_consultation_visibility_levels
        @opening_date_range_separator = get_opening_date_range_separator
      end

      def create
        @consultation_form = ConsultationForm.new(
          consultation_params.merge(
            admin_id: current_admin.id,
            site_id: current_site.id
          )
        )

        if @consultation_form.save
          redirect_to(
            admin_budget_consultation_consultation_items_path(@consultation_form.consultation),
            notice: t(".success")
          )
        else
          @consultation_visibility_levels = get_consultation_visibility_levels
          @opening_date_range_separator = get_opening_date_range_separator
          render :new
        end
      end

      def update
        @consultation = find_consultation
        @consultation_form = ConsultationForm.new(
          consultation_params.merge(id: params[:id])
        )

        if @consultation_form.save
          redirect_to(
            edit_admin_budget_consultation_path(@consultation),
            notice: t(".success")
          )
        else
          @consultation_visibility_levels = get_consultation_visibility_levels
          @opening_date_range_separator = get_opening_date_range_separator
          render :edit
        end
      end

      private

      def find_consultation
        current_site.budget_consultations.find(params[:id])
      end

      def get_consultation_visibility_levels
        ::GobiertoBudgetConsultations::Consultation.visibility_levels
      end

      def get_opening_date_range_separator
        ConsultationForm::OPENING_DATE_RANGE_SEPARATOR
      end

      def consultation_params
        params.require(:consultation).permit(
          :title,
          :description,
          :opening_date_range,
          :visibility_level,
          :show_figures,
          :force_responses_balance
        )
      end

      def ignored_consultation_attributes
        %w( created_at updated_at budget_amount )
      end
    end
  end
end
