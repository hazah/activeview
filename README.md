## Active View

### Motivation

> The _View layer_ is composed of "templates" that are responsible for providing appropriate
> representations of your application's resources. Templates can come in a variety of formats,
> but most view templates are HTML with embedded Ruby code (ERB files). Views are typically
> rendered to generate a controller response, or to generate the body of an email. In Rails,
> View generation is handled by Action View.

Rails does a great job of routing a request to the correct template and ensuring that it has
access to an environment suitable for fulfilling the request. Even though this removes many
concerns into a separate domain and allows one to enrich the request environment up front, by
the time one is inside one of these "templates" of representation, the benefit of the Rails
framework is reduced to procedural template code that resembles typical, hap-hazardly
structured preproccessed markup.

A cursory glance at typical application response templates yields many combinations of
embedded logic coupled with includes of other templates, all of which are augmented by a
global system of helper modules providing a gateway for code processing outside of the
typical flow of the template itself. Apart from builder classes for forms, which are thin
wrapper objects around global helpers that facilitate additional apis for the proper submission
of forms, Rails' support for structured application logic ends.

#### Enter _Active View_...

Active View is an application mini-framework that includes the components for creating views
according to the
[Model-View-Presenter (MVP)](https://en.wikipedia.org/wiki/Model-view-presenter)
pattern.

Understanding the MVP pattern is the key to understanding Active View. MVP Divides your view
logic into three layers, each with a specific responsbility. The model layer is handled by
Rails. From the [README](https://github.com/rails/rails/blob/master/README.md).

> The _Model layer_ represents your domain model (such as Account, Product,
> Person, Post, etc.) and encapsulates the business logic that is specific to
> your application. In Rails, database-backed model classes are derived from
> `ActiveRecord::Base`. Active Record allows you to present the data from
> database rows as objects and embellish these data objects with business logic
> methods. You can read more about Active Record in its README.Although most
> Rails models are backed by a database, models can also be ordinary Ruby
> classes, or Ruby classes that implement a set of interfaces as provided by
> the Active Model module.

The _View layer_ represents your _Model layer_, and encapsulates the view logic that
is spcecific to your model and optionally binds it to a template. In Active View,
view classes are derived from `ActiveView::Base`. They, by design, are excuted in the
context of an action of the Rails Action Controller. Active View allows you to embellish
your model with view logic methods. Used directly within templates, these objects
are self contained units of rendered data suitable for direct output. In this role
they are treated as models themselves, thus act as _Model Presenters_ or _View Models_
(related patterns, but not part of MVP itself) which decorate their models for the view.
Furthermore, These objects can themselves be passed to the render method, in which
case a corresponding template, much like a partial, with the object as the view context
is used for the output. As it is rendered, the template will have access to the methods
and instance variables of the view object.

The _Presenter layer_ is responsible for handling the initialization and executing
commands on behalf of the view. Presenters load and manipulate models, giving the view
the state and metadata it needs to produce its own renderable data and render itself
based on the context in which it needs to do so. In Active View, during lifecycle of
the view object, the presenter is invoked to process specific actions, which manipulate
the state of the view.

#### The end result is a framework that allows for independent in-app components to be developed, potentially as self contained content blocks, widgets, forms, builders, and more.

# Installation

## Directory structure

* actions/models/[resource]/{show,form}.rb
* actions/presenters/[resource]_{show,form}.rb
* actions/views/[resource]/{show,form}.html.erb

## Examples

TODO: Clarity through code...

Lets us take the infamous blog example where we have a Post model with a title and a body,
a standard PostsController with all resource routes enabled and the corresponding template
files.

```ruby

## db/create_posts.rb

class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body

      t.timestamps null: false
    end
  end
end

## models/post.rb
class Post < ActiveRecord::Base
  validates_presense_of :title
end

## controllers/application_controller.rb
class ApplicationController < ActionController::Base
  private

  def post_params
    [:title, :body]
  end

  helper_method :post_params
end

## controllers/posts_controller.rb
class PostsController < ApplicationController

  def index
    @posts = Post.all
  end

end

```

```ruby

## views/posts/index.html.erb
<%= view(Post::Show, @posts) %>

```

```ruby

## controllers/posts_controller.rb

class PostsController < ApplicationController

  def show
    @post = Post.find params[:id]
  end

end
```

```ruby

## views/posts/show.html.erb
<%= view(Post::Show, @post) %>

```

```ruby

## controllers/posts_controller.rb

class PostsController < ApplicationController

  def new
    @post = Post.new
  end

end

```

```ruby

## views/posts/new.html.erb
<%= view(Post::Form, @post) %>

```

```ruby

## controllers/posts_controller.rb

class PostsController < ApplicationController

  def edit
    @post = Post.find params[:id]
  end

end

```

```ruby

## views/posts/edit.html.erb

<%= view(Post::Form, @post) %>

```

Note that the following actions render the form directly. This is because it is a view.
Therefore, we do not need a template to handle this action!
Note, also, that we are not passing parameters around. Since we've handed off the
model to a view, the parameters will still be available in that context.

```ruby

## controllers/posts_controller.rb

class PostsController < ApplicationController

  def create
    @form = view(Post::Form, Post.new)
    if @form.submitted?
      redirect_to @form.post
    else
      render @form
    end
  end

end


## controllers/posts_controller.rb

class PostsController < ApplicationController

  def update
    @form = view(Post::Form, Post.find(params[:id]))
    if @form.submitted?
      redirect_to @form.post
    else
      render @form
    end
  end

end


## We still forward to the form for destroy operation.


## controllers/posts_controller.rb

class PostsController < ApplicationController

  def destroy
    @form = view(Post::Form, Post.find(params[:id]))
    if @form.submitted?
      redirect_to Posts
    end
  end
end


```

Now that we have handed off our model to the view layer, it's time to take over rendering.

```ruby

## actions/models/show.rb

class Post::Show < ActiveView::Base
  ## Lets show off some features...

  # Signal that this is a resource view
  resource

  # helper methods
  def header_tag
    # The implication is that this might be rendered from a different action/controller
    # combination.

    params[:controller] == 'posts' && params[:action] == 'show' ? :h1 : :h2
  end

  def model_name
    Post.model_name.human
  end

  # helper overrides!
  def current_page?(action)
    super(controller: :posts, action: action)
  end

  # wrapper helpers work too!
  def post_link(action, link_content, destination, options={})
    link_to_unless(current_page?(action), content, destination, options) {}
  end

  def index_link
    post_link :index, model_name, Post
  end

  def show_link
    post_link :show, title, post
  end

  def new_link
    post_link :new, t(:create, model: model_name.singularize), post
  end

  def edit_link
    post_link :edit, t(:edit, model: title), edit_post(post)
  end

  def destroy_link
    post_link :destroy, t(:destroy, model: title), post, method: :destroy
  end

  # access to the object's attributes directly as helpers as well.
  attr_helper :title, :body

end

```

```ruby

## actions/views/post/show.rb

<%= div_for post do %>
  <div class="back-link"><%= index_link %></div>
  <%= content_tag header_tag, title %>
  <p><%= body %></p>
  <ul class="links">
    <li><%= edit_link %></li>
    <li><%= destroy_link %></li>
  </ul>
<% end %>

```

```ruby

# actions/models/post/form.rb

class Post::Form < ActiveView::Form
  # We declare all the input fields and their options which will be used
  # to inform the form builder.
  input :title, :body
end


## actions/presenters/application_presenter.rb

class ApplicationPresenter < ActiveView::Presenter
end


# actions/presenters/post_presenter.rb

class Post::Presenter < ApplicationPresenter
  # Standard form operations
  def populate
    post.assign_attributes post_params
  end

  def validate
    post.validate
  end

  def create
    post.save
  end

  def update
    post.save
  end

  def destroy
    post.destroy
  end

  private

  def post_params
    params[:post].permit *view.post_params if params.has_key? :post
  end

  helper_method :post, :post_params
end

```

```ruby

# actions/views/posts/form.html.erb

<%= form_for post do |post_form| %>
  <% if post.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(post.errors.count, "error") %> prohibited this <%= model_name %> from being saved:</h2>

      <ul>
       <%= post.errors.full_messages.each do |message| %>
        <li><%%= message %></li>
       <% end %>
      </ul>
    </div>
  <% end %>

  <div class="field">
    <%= post_form.label :title %>
    <%= post_form.input :title %>
  </div>

  <div class="field">
    <%= post_form.label :body %>
    <%= post_form.input :body %>
  </div>

  <div class="actions">
    <%= post_form.submit %>
  </div>
<% end %>

```



# Emergent patterns

Some design patterns enabled by this framework are a happy coincidence. Nevertheless, since
they are enabled by the framework, how they may be applied warrants a closer investigation.

## _Model Presenters_

Mentioned above, is the ability for a view object to be treated as a model object by the
outside world. This enables a pattern where this object is used to obtain formatted data
suitable for rendering by querying the object directly. Since it is a true view, and is
responsible for generating rendered content, the object's properties can used to generate
rendered data from any conroller and by extention, view, context. Effectively this means
that once we obtain a view object, we can collect rendered information in an arbitrary
fashion.

### Examples

TODO: Clarity through code...

## _View Models_

At the most basic level, the presenter does only what is conventional of a typical rails
action. Presenters treat the external controller actions as context information from which
to derive their state. This means that without any further extension to the presenter, the
view simply acts as a simple binder for the rendering template.

### Examples

TODO: Clarity through code...

## _Services_

Taking advantage of the presenter, when one returns a view as a response to an action it's
possible to make use of the callback mechanism and the actions of the presenter to execute
various operations. This is essentially how the form submission mechanism works in the
standard resource oriented application using Active View.

The command sequence for the form looks like this:

```ruby

after_initialize { |view| process(:populate) if populate? }
after_initialize { |view| process(:validate) if validate? }
after_initialize { |view| process(operation) if submit?   }

delegate :populate?, :validate?, :submit?, :valid?, :submitted?, :operation, to: :presenter

```

The implementation of `ActiveView::Presenter`:

```ruby

around_action :validate, :set_valid
after_action :create, :update, :set_submitted

def populate?
  # Only populate if the calling controller matches the intended resources.
  # Otherwise the assumption is that the object was populated by
  # accepts_nested_attributes_for.
  validate? && params[:controller].singularize == view.view_path.rpartition('/').first
end

def validate?
  [:create, :update].include? params[:action]
end

def submit?
  should_submit = [:create, :update, :destroy].include? params[:action]
  should_submit = should_submit && valid? if validate?
  should_submit
end

def operation
  params[:action]
end

def valid?
  @_valid ||= false
end

def submitted?
  @_submitted ||= false
end

private

def set_valid
  @_valid = yield
end

def set_submitted
  @_submitted = true
end

```

## _Builders_

When you override the object that is passed into the block sent with the call to `render` to
collect custom configuration, add callbacks to various points in the lifecycle of the
view to execute actions on the presenter, take advantage of layouts and collection rendering,
and add some custom state, the possibilities of the resulted output are probably endless for
generic, extensible themeing components or any other purely renderable structure.

### Examples

TODO: Clarity through code...
