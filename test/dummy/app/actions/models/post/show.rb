class Post::Show < ActiveView::Base
  def header_tag
    current_page?(:show) ? :h1 : :h2
  end

  def model_name
    Post.model_name.human
  end

  def current_page?(action)
    options = { controller: 'posts', action: action }
    options[:id] = @post.id unless @post.nil? || action == :index
    super(options)
  end

  def post_link(action, link_content, destination, options={})
    return link_to_unless(current_page?(action), link_content, destination, options) {} unless action == :destroy
    link_to link_content, destination, options
  end

  def index_link
    post_link :index, model_name.pluralize, Post
  end

  def show_link
    post_link :show, @post.title, @post
  end

  def new_link
    post_link :new, t(:create, model: model_name.singularize), @post
  end

  def edit_link
    post_link :edit, t(:edit, model: @post.title), edit_post_path(@post)
  end

  def destroy_link
    post_link :destroy, t(:destroy, model: @post.title), @post, method: :destroy
  end
end
