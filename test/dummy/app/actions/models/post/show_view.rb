class Post::ShowView < ActiveView::Base
  attribute :title, :body

  validates_presence_of :title

  def edit_link
    link_to 'Edit', self
  end

  def back_link
    link_to 'Back', model_class
  end
end
