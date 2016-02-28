class Post::Show < ActiveView::Base
  include PostView

  layout 'post'

  def header_tag
    unless current_page?(:show)
      content_tag :h2 do
        show_link
      end
    end
  end

  def edit_link
    post_link :edit, t(:edit, model: model_name), [:edit, @post]
  end

  def destroy_link
    post_link :destroy, t(:destroy, model: model_name), @post, method: :destroy
  end
end
