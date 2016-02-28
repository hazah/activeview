class Post::Index < ActiveView::Base
  include ::PostView

  def new_link
    post_link :new, t(:create, model: model_name), new_post_path
  end

  def posts
    @posts.each do |post|
      @view.populate(post)
      yield @view
    end
  end
end
