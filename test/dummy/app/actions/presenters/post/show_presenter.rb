class Post::ShowPresenter < ActiveView::Presenter
  before_action :show, :set_extra_var

  private

  def set_extra_var
    @extra_var = "Extra variable."
  end
end
