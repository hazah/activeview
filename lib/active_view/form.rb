module ActiveView
  class Form < ActiveView::Base
    abstract!

    # We want to render invalid forms as well since we this allows to relay errors
    # to the user.
    def renderable?
      run_callbacks :renderable do
        true
      end
    end
  end
end
