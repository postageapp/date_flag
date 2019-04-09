# Simple Date Flag Support for Rails

This is a date flag method for ActiveRecord models and works with Rails 3.x
or newer.

A date flag is a DATETIME type column that behaves as a boolean. This helps
when tracking things such as if article is published or if a user is banned
while preserving information about when that event did or should occur.

Dates can be in the past or in the future and the meaning of the flag is
subjective.

## Installation

This can be installed as a Ruby gem by adding the following to your `Gemfile`:

    gem 'date_flag'

## Usage

Inside your model if you have a column `banned_at`:

    date_flag :banned_at

This will introduce methods `banned?` for quick testing and `banned!` for
immediately setting this flag and saving the record. There's also a `banned`
scope established for that model.

There are several options that can customize the name of the methods:

* `:name` defines the base name for this flag and defaults to the name of the
column minus the trailing `_at`.
* `:scope` can be set to a a symbol or string, in which case that's the name of
the generated scope, to `false` to skip creating the scope.
* `:inverse` can be set with a symbol or string which will create a scope of
this name that behaves in the opposite manner to the main scope.
* `:action` can be set with a symbol or string that defines the name used
when generating accessor methods.
* `:inverse_action` can be set with a symbol or string which will create a
method to unset the flag with the supplied name. If `:inverse` is set, that
name will be used by default.

These might be used together like this:
   
    date_flag :was_published_at,
      name: :published,
      scope: :published,
      inverse: :unpublished,
      inverse_action: :unpublish!,
      action: :publish

This results in instance methods `publish!` but the scopes are named
`published` and `unpublished`. The flag itself is also available via the
`published?` and `published=` methods.

## License

(C) 2009-2019 Scott Tadman, [PostageApp Ltd.](https://postageapp.com/)
