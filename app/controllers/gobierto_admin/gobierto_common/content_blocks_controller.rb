# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class ContentBlocksController < BaseController
      def index
        content_block_policy = ContentBlockPolicy.new(current_admin)
        raise Errors::NotAuthorized unless content_block_policy.view?

        @content_blocks = current_site.content_blocks.sorted
      end

      def show
        @content_block = find_content_block

        content_block_policy = ContentBlockPolicy.new(current_admin, @content_block)
        raise Errors::NotAuthorized unless content_block_policy.view?
      end

      def new
        content_block_policy = ContentBlockPolicy.new(current_admin)
        raise Errors::NotAuthorized unless content_block_policy.create?

        @content_block_form = ContentBlockForm.new(
          content_model_name: get_content_model_name_from_params,
          referrer_url: request.referrer,
          available_locales: available_locales
        )
      end

      def edit
        @content_block = find_content_block

        content_block_policy = ContentBlockPolicy.new(current_admin, @content_block)
        raise Errors::NotAuthorized unless content_block_policy.update?

        @content_block_form = ContentBlockForm.new(
          @content_block.attributes
            .except(*ignored_content_block_attributes)
            .merge(
              referrer_url: request.referrer,
              available_locales: available_locales
            )
        )
      end

      def create
        content_block_policy = ContentBlockPolicy.new(current_admin)
        raise Errors::NotAuthorized unless content_block_policy.create?

        @content_block_form = ContentBlockForm.new(
          content_block_params.merge(
            site_id: current_site.id,
            available_locales: available_locales
          )
        )

        if @content_block_form.save
          redirect_to(
            @content_block_form.referrer_url.presence || edit_admin_common_content_block_path(@content_block_form.content_block),
            notice: t(".success")
          )
        else
          render :new
        end
      end

      def update
        @content_block = find_content_block

        content_block_policy = ContentBlockPolicy.new(current_admin, @content_block)
        raise Errors::NotAuthorized unless content_block_policy.update?

        @content_block_form = ContentBlockForm.new(
          content_block_params.merge(
            id: params[:id],
            available_locales: available_locales
          )
        )

        if @content_block_form.save
          redirect_to(
            @content_block_form.referrer_url.presence || edit_admin_common_content_block_path(@content_block),
            notice: t(".success")
          )
        else
          render :edit
        end
      end

    def destroy
      @content_block = find_content_block

      content_block_policy = ContentBlockPolicy.new(current_admin, @content_block)
      raise Errors::NotAuthorized unless content_block_policy.delete?

      @content_block.destroy

      redirect_to request.referrer, notice: t(".success")
    end

      private

      def find_content_block
        current_site.content_blocks.find(params[:id])
      end

      def get_content_model_name_from_params
        params[:content_context]
      end

      def content_block_params
        params.require(:content_block).permit(
          :content_model_name,
          :referrer_url,
          title_components_attributes: [:locale, :value],
          fields_attributes: [
            :id,
            :_destroy,
            :field_type,
            label_components_attributes: [:locale, :value]
          ]
        )
      end

      def ignored_content_block_attributes
        %w(
        created_at updated_at internal_id
        )
      end
    end
  end
end
