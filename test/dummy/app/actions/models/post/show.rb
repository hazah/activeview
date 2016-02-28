class Post::Show < ActiveView::Base
  include ::PostView

  layout 'post'

  def header_tag
    current_page?(:show) ? :h1 : :h2
  end

  def index_link
    post_link :index, model_name.pluralize, Post
  end

  def show_link
    post_link :show, @post.title, @post
  end

  def edit_link
    post_link :edit, t(:edit, model: model_name), edit_post_path(@post)
  end

  def destroy_link
    post_link :destroy, t(:destroy, model: model_name), @post, method: :destroy
  end
end
