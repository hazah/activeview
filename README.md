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

  def permitted_post_params
    [:title, :body]
  end

  def post_params
    params.require(:post).permit(permitted_post_params)
  end

  helper_method :permitted_post_params, :post_params
end

## controllers/posts_controller.rb
class PostsController < ApplicationController

  def index
    @posts = Post.all
    @view = view(Post::Index)

    @view.populate(@posts, Post::Show)
  end

  def show
    @post = Post.find params[:id]
    @view = view(Post::Show)

    @view.populate(@post)
  end

  def new
    @post = Post.new
    @form = view(Post::Form)

    @form.populate(@post)
  end

  def edit
    @post = Post.find params[:id]
    @form = view(Post::Form)

    @form.populate(@post)
  end

  def create
    @post = Post.build
    @form = view(Post::Form)

    @form.populate @post, post_params
    @form.validate
    @form.submit if @form.valid?

    if @form.submitted?
      redirect_to @post
    else
      render :new
    end
  end

  def update
    @post = Post.find(params[:id])
    @form = view(Post::Form)

    @form.populate @post, post_params
    @form.validate
    @form.submit if @form.valid?

    if @form.submitted?
      redirect_to @post
    else
      render :edit
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    redirect_to Posts
  end

end

```

Though the action's primary templates' code shown here is as brief as possible,
it is assumed to contain logic pertaining directly to the request being viewed.
In a real world application, we can still assume typical use of helpers and other
partials. In fact, this framework does not discourage standard Rails practices.

Note that we render the `@view` or the `@form` instance variables.

```ruby

## views/layouts/application.html.erb

<!DOCTYPE html>
<html>
<head>
  <title>Dummy</title>
  <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
  <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
  <%= csrf_meta_tags %>
</head>
<body>

<p id="notice"><%= notice %></p>
<%= yield %>

</body>
</html>

## views/posts/index.html.erb
<%= @view.new_link %>
<%= content_tag :h1, t(:listing, model: @view.model_name.pluralize) %>
<%= render @view %>


## views/posts/show.html.erb
<%= content_tag :div, @view.index_link, class: 'back-link' %>
<%= content_tag :h1, @view.show_link %>
<%= render @view %>


## views/posts/new.html.erb
<%= content_tag :h1, t(:create, model: @form.model_name) %>

<%= render @form %>

<ul class="links">
  <li><%= @form.index_link %></li>
</ul>


## views/posts/edit.html.erb
<%= content_tag :h1, t(:edit, model: @form.model_name) %>

<%= render @form %>

<ul class="links">
  <li><%= @form.index_link %></li>
  <li><%= @form.show_link %></li>
</ul>

```

Now that we have handed off our model to the view layer of the MVP framework, it's
time to take over the rendering logic, finally! To do this we implement actions
on the presenters.

Presenter actions, like controller actions, are used to retrieve
data from the model layer and the view layer (as created by the Rails environment).
However, one can execute commands on a view from any context exept models and
presenters themselves (they cannot create views). This means that we can make use
of the request information as well as the command sequence that gets executed along
with the data that is passed in to these commands.

```ruby
## actions/models/concerns/post_view.rb

module PostView
  extend ActiveSupport::Concern

  def post_link(action, link_content, destination, options={})
    unless action == :destroy
      return link_to_unless(current_page?(action), link_content, destination, options) { link_content if action == :show}
    end
    link_to link_content, destination, options
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


# actions/models/post/index.rb

class Post::Index < ActiveView::Collection
  include PostView

  def new_link
    post_link :new, t(:create, model: model_name), new_post_path
  end
end


## actions/models/show.rb

class Post::Show < ActiveView::Base
  include PostView

  def header_tag
    # The implication is that this might be rendered from a different action/controller
    # combination.

    current_page?(:show) ? :h1 : :h2
  end

  def index_link
    post_link :index, model_name, Post
  end

  def show_link
    post_link :show, title, @post
  end

  def edit_link
    post_link :edit, t(:edit, model: title), edit_post(@post)
  end

  def destroy_link
    post_link :destroy, t(:destroy, model: title), @post, method: :destroy
  end

end


# actions/models/post/form.rb

class Post::Form < ActiveView::Form
  # By default, the forms' presenter will contain
  # basic form processing actions suitable for a
  # scaffolded view.
end

## actions/presenters/application_presenter.rb

class ApplicationPresenter < ActiveView::Presenter
  # This is the controller's cousin. it's job is to respond to the commands
  # performed on the view and set it's state. It does so by manipulating models.
end


# actions/presenters/post_presenter.rb

class Post::Presenter < ApplicationPresenter
  # Map some attributes as helpers for the view.
  attr_accessor :title, :body
  helper_attr :title, :body

  ## Standard form operations on resources. Each is implemented as an action
  ## (similar to an ActionController action). Each of which can have before,
  ## after, and around filters defined.

  def populate(post, params = nil)
    @post = post

    @post.assign_attributes params if params

    # set the attributes so that they can be used
    self.title = @post.title
    self.body = @post.body
  end

  def validate
    @post.validate
  end

  def submit
    @post.save
  end

end

```

And now, the moment of truth, the actual rendering of the views!

```ruby

## actions/views/post/index.rb

<% collection.each do |post| %>
  <%= render post %>
<% end %>

## actions/views/post/show.rb

<%= div_for @post do %>

  <%= header_tag %>

  <div class="body">
    <p><%= body %></p>
  </div>

  <ul class="links">
    <li><%= edit_link %></li>
    <li><%= destroy_link %></li>
  </ul>

<% end %>

# actions/views/posts/form.html.erb

<%= form_for @post do |form| %>

  <% if @post.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(@post.errors.count, "error") %> prohibited this <%= model_name %> from being saved:</h2>

      <ul>
       <%= @post.errors.full_messages.each do |message| %>
        <li><%%= message %></li>
       <% end %>
      </ul>
    </div>
  <% end %>

  <div class="field">
    <%= form.label :title %>
    <%= form.text_field :title %>
  </div>

  <div class="field">
    <%= form.label :body %>
    <%= form.text_area :body %>
  </div>

  <div class="actions">
    <%= form.submit %>
  </div>

<% end %>

```

At first glance it may seem that we've just pushed the logic down to another layer.
In the case of a simple application such as this demonstration, this observation is
justified.

A second glance may be more revealing. For instance, note that while we technically
added more lines of code to the actions of the controller, we are ultimately
separating the concerns of the request with the concerns of that request's fulfilment.
The controller responds to a request by acting on models and then binding them to
views and rendering them. The view, on the other hand is responsible for properly
setting itself up for the rendering of that response. That being the case, it's
entierly possible that the rendering needs of the view are independent of the controller.
This happens in applications where the rendering needs are primarily driven through
user configuration.

A very careful glance might make one ponder "what happened to the index action view
template?" We simply didn't have to implement one. The interface to views is designed
to keep to the familiar pattern of rendering partials from within templates. This means
we can render collections of objects using a simple expression. Thus, we retain the Rails
interface where from the perspective of the template itself, it is simply rendering
various objects.

# Emergent patterns

Some design patterns enabled by this framework are a happy coincidence. Nevertheless, since
they are enabled by the framework, how they may be applied warrants a closer investigation.

## _Model Presenters_

Mentioned above, is the ability for a view object to be treated as variable by the
outside world. This enables a pattern where this object is used to obtain formatted data
suitable for rendering by querying the object directly. Since it is a true view, and is
responsible for generating rendered content, the object's properties can used to generate
rendered data from any controller and by extention, view, context. Effectively this means
that once we obtain a view object, we can collect rendered information in an arbitrary way.

```ruby

def flashy_show
  @post = Post.find params[:id]
  @view = view(Post::Show)
  @view.populate @post

  flash[:link_to_self] = @view.post_link
  redirect_to :show
end

# views/posts/show.html.erb

<%= flash[:link_to_self] %>
<%= @view.index_link %>

```

## _View Objects_

Drawing on the example above, we can create a simple view object that isn't extended
in any way. Once we create an instance of this object, we can pass it around and have
access to all available rendering helpers! How can this be useful? Lets say you have
an update action where you would like to save some markup to the database. Current
solutions to this issue are essentially _antipatterns_ that deliberately break
abstraction boundries. One one end of the spectrum we have this functionality brought
directly either into the controller or model. In terms of separation of concerns, we
end up with "swiss cheese". On the other end of that spectrum we have additional
abstraction layers that bring about their own patters for separating concerns forcing
us to facilitate generic pattern translations and also adaptations for special cases.

By contrast, having a standard view, derived from Action View to pass around as a
variable embued with the same functionality means that not only are we leaving all
rendering concerns to the view layer where they belong, it also means that we gain
all of that functionality from a well defined interface without actually adding any
more layers. Even the MVP abstractions themselves serve the same concerns as the
MVC ones with the difference being in their arrangements.


```ruby
# models/post.rb
def set_author_html(view, author)
  author_html = "Written by #{view.content_tag :em, author.name}."
end
```

Since we can add methods to our basic view class we can adopt it to a more generic
interface, where any kind of `view` parameter can be passed in to this method as long
as it supports that interface.

In the following example `caching_view` may be an Active View instance, but it could
very well be a view that generates JSON, XML or PDF. The actual limit is only set
by the interface expected of the view objects themselves.

```ruby

# controllers/posts_controller.rb

class PostsController < ApplicationController
private
  def generate_cached_html
    generate_cached_content(view(Post::Show))
  end

  def generate_cached_xml
    generate_cached_content(XmlBuilder.new(self))
  end

  def generate_cached_json
    generate_cached_content(JsonBuilder.new(self))
  end

  def generate_cached_content(caching_view)
    caching_view.cached_content_for_post(title, body)
  end
end

```

## _View Models_

At the most basic level, the presenter does only what is conventional of a typical rails
action. Presenters treat the external controller actions as context information from which
to derive their state. But, by design, which actions are called is left up to the context
within which the view is used. If we reserve the presenter for only defining helper
attributes and helpers, and direct view helpers, we have a an object that acts as a data
binder for the associated template. Since we have an option of using the view as an object,
we can set the attributes, and call the methods created on the view directly. Unlike
presenter actions, the intention here is direct binding of data, thus, we only deal with
rendering concerns.

```ruby

## The view acts as the main binder interface. Usually as a series of helpers.
## For this example the same implementation as before is sufficient.
class Post::ViewModel < ActiveView::Base

  def header_tag
    params[:controller] == 'posts' && params[:action] == 'show' ? :h1 : :h2
  end

  def model_name
    Post.model_name.human
  end

  def current_page?(action)
    super(controller: :posts, action: action)
  end

  def post_link(action, link_content, destination, options={})
    link_to_unless(current_page?(action), content, destination, options) {}
  end

  def index_link
    post_link :index, model_name, Post
  end

  def show_link
    post_link :show, title, @post
  end

  def new_link
    post_link :new, t(:create, model: model_name.singularize), @post
  end

  def edit_link
    post_link :edit, t(:edit, model: title), edit_post(@post)
  end

  def destroy_link
    post_link :destroy, t(:destroy, model: title), @post, method: :destroy
  end

end

## The presenter is implemented to only define helpers for the view that work out
## the binding logic.
class Post::Presenter < ApplicationPresenter
  attr_accessor :title, :body
  helper_attr :title, :body
end

## the template (looking curiously the same as before...)

<%= div_for @post do %>

  <%= unless current_page?(:index) || params[:controller] != 'posts' %>
    <%= content_tag :div, class: 'back-link' %>
      <%= index_link %>
    <% end %>
  <% end %>

  <%= content_tag header_tag, title %>

  <div class="body">
    <p><%= body %></p>
  </div>

  <ul class="links">
    <li><%= edit_link %></li>
    <li><%= destroy_link %></li>
  </ul>

<% end %>

```
```ruby

## the outside world

class PostController < ApplicationController

  def show
    @post = Post.find params[:id]

    # We can render views directly from an action.
    render Post::ViewModel do |view|
      view.title = @post.title
      view.body = @post.body
    end
  end

end

```

## _Services_

Taking advantage of the presenter, when one creates a view inside of a controller'a action
it's possible to make use of the callback mechanism and the actions of the presenter to
execute various operations. This is essentially how the form submission mechanism works
for the standard resource oriented application using Active View.

```ruby

@form = view(Post::Form)

@form.populate @post, post_params
@form.validate
@form.submit if @form.valid?

success =  @form.submitted?

```
## _Builders_

When you override the object that is passed into the block sent with the call to `render` to
collect custom configuration, add callbacks to various points in the lifecycle of the
view to execute actions on the presenter, take advantage of layouts and collection rendering,
and add some custom state, the possibilities of the resulted output are probably endless for
generic, extensible themeing components or any other purely renderable structure.

```ruby
<%= render Bootstrap::Table, { args: [ @posts, :striped, :hover] } do |table| %>
  <%= table.column :id, header: '#' %>
  <%= table.column :title %>
  <%= table.timestampts %>
  <%= table.actions %>
<% end %>
```
