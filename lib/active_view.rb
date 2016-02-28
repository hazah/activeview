require 'action_view/helpers'
require 'active_model'

require 'active_view/rails/engine/configuration'
require 'active_view/rails/engine'
require 'active_view/rails/action_view/helpers/rendering_helper'
require 'active_view/rails/action_view/renderer/renderer'
require 'active_view/rails/action_controller/base'

require 'active_view/engine'

require 'active_support'
require 'active_support/rails'

module ActiveView
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :Base
    autoload :Rendering
    autoload :Layouts
    autoload :Form
    autoload :Collection

    autoload_under "renderer" do
      autoload :ViewRenderer
    end

    autoload_under "presenter" do
      autoload :Presenter
      autoload :FormPresenter
      autoload :CollectionPresenter
    end
  end
end
