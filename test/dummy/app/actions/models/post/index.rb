class Post::Index < ActiveView::Collection
  include PostView

  def new_link
    post_link :new, t(:create, model: model_name), new_post_path
  end
end
