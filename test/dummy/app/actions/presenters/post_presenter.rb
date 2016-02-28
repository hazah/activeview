class PostPresenter < ActiveView::Presenter
  attr_accessor :title, :body
  helper_attr :title, :body

  def populate(post, params = nil)
    if post.is_a? ActiveRecord::Base
      @post = post

      @post.assign_attributes params if params

      self.title = @post.title
      self.body = @post.body
    else
      @view = post
      @posts = params
    end
  end

  def validate
    @post.validate
  end

  def submit
    @post.save
  end
end
