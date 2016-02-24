class Post::Presenter < ActiveView::Presenter
  before_action :show, :set_extra_var

  def form
    view.post.assign_attributes post_params
  end

  def validate
    view.post.valid?
  end

  def create
    view.post.save
  end

  def update
    view.post.save
  end

  def destroy
    view.post.destroy
  end

  private

  def set_extra_var
    @extra_var = "Extra variable."
  end

  def post_params
    params[:post].permit view.post_params
  end
end
