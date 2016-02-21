class Post::ShowView < ActiveView::Base
  delegate :title, :body, to: :object

  def edit_link
    link_to 'Edit', self
  end

  def back_link
    link_to 'Back', model_name.name.constantize
  end
end
