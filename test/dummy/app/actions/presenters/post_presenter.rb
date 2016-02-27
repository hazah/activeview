class PostPresenter < ActiveView::Presenter
  #before_action :initialize_view, :set_extra_var

  attr_accessor :title, :body
  helper_attr :title, :body

  def populate(post, params = nil)
    @post = post

    @post.assign_attributes params if params

    self.title = @post.title
    self.body = @post.body
  end

  def validate
    @post.validate
  end

  def submit
    @post.save
  end

  private

  def set_extra_var
    @extra_var = "Extra variable."
  end
end
