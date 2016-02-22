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
view classes are derived from `ActiveView::Base`. Active View allows you to embellish
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
based on the context in which it needs to do so.

#### The end result is a framework that allows for independent in-app components to be developed, potentially as self contained content blocks, widgets, forms, and more.

# Installation

## Directory structure

* actions/models/[resource]/{show,form}.rb
* actions/presenters/[resource]_{show,form}.rb
* actions/views/[resource]/{show,form}.html.erb

# Examples

TODO: Clarity through code...
