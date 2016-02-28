module PostView
  extend ActiveSupport::Concern

  def post_link(action, link_content, destination, options={})
    unless action == :destroy
      return link_to_unless(current_page?(action), link_content, destination, options) { link_content if action == :show}
    end
    link_to link_content, destination, options
  end

  def index_link
    post_link :index, model_name.pluralize, Post
  end

  def show_link
    post_link :show, @post.title, @post
  end

  def model_name
    Post.model_name.human
  end

  def current_page?(action)
    options = { controller: 'posts', action: action }
    options[:id] = @post.id unless @post.nil? || action == :index
    super(options)
  end
end
