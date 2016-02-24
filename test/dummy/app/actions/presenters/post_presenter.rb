class Post::Presenter < ActiveView::Presenter
  before_action :show, :set_extra_var

  def populate
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

  def post
    view.object
  end

  helper_method :post

  def set_extra_var
    @extra_var = "Extra variable."
  end
end
