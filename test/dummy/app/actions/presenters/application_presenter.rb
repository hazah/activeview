class ApplicationPresenter < ActiveView::Presenter
  private

  def post_params
    # If this is a nested form, simply obtain the already sanitized hash from the
    # parent form.
    return parent_params[:post_attributes] if parent_params.has_key? :post_attributes

    # view.post_params is a helper in ApplicationController
    params[:post].permit view.post_params if params.has_key? :post
  end

  helper_method :post_params
end
