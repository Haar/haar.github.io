---
title: Cheating at Railway Oriented Programming in Elixir
date: 2017-07-15
tags: Elixir, Software Architecture, Design Techniques
layout: post
---

Over the past four months I've been writing Elixir full-time for backend systems. From this I'll be releasing a series of small blog posts about techniques we utilise, and the advantages and disadvantages that we've found whilst using them.

The first as the title suggests relates to Railway Oriented Programming as presented by Scott Wlaschin [here](https://vimeo.com/97344498). If you haven't watched the video and you are interested in functional programming techniques I would highly you stop right here and go watch it.

To summarise, Railway Oriented Programming is a technique designed to allow a program to proceed through to completion should it fail at any point, with a uniform error handling that allows you to compose functions as you would aim to in a "perfect" world. The pain-points to consider with functional programming are around the lack of early returns, exceptions, and modelling stateful data. A blog post around directly implementing those design patterns can be found [here](http://www.zohaib.me/railway-programming-pattern-in-elixir/).

The initial example from the talk is the following hypothetical:

``` elixir
def update_user_preferences(conn, request)
  request
  |> validate_request
  |> get_user
  |> update_db_from_request
  |> send_email
  |> return_http_message
end
```

A close equivalent set of functionality utilising the `with` macro would be:

``` elixir
def update_user_preferences(conn, request)
  with {:ok, request}    <- validate(request),
       {:ok, user}       <- fetch_user(request.user_id),
       {:ok, _}          <- update_preferences(user, request.preferences),
       {:ok, sent_email} <- send_email(user, :preferences_updated)
  do
    return_http_message(conn, user, sent_mail)
  end
end
```

This functionality is dependent on the return "shape" to be pattern matched, using the standard convention of returning either an ok tuple (`{:ok, result}`), or an error tuple (`{:error, # ...}`). It provides us a uniform error handling by propogating the error that occurred back up the call chain, or allows us to pattern match the error in a provided else-clause, like so:

``` elixir
def update_user_preferences(conn, request)
  with {:ok, request}    <- validate(request),
       {:ok, user}       <- User.fetch(request.user_id),
       {:ok, _}          <- User.update_preferences(user, request.preferences),
       {:ok, sent_email} <- send_email(user, :preferences_updated)
  do
    return_http_message(conn, user, sent_mail)
  else
    # Three-form error tuples will be the topic for another blog-post
    {:error, :validation, errors} -> render_as_json(errors)
    {:error, :user, :not_found}   -> # ...
  end
end
```

We also regain the notion of stateful data. With it the you gain the flexibility to design functions around their purpose without needing utility functions to wrap them in order to connect the tracks nicely (you have the complete past scope to work with, not just what was passed in). A correct-in-spirit-but-not-quite way to imagine it is as a set of composed case statements, with the error handling injected as pattern matches in each of the cases. This provides us with access to any of the parent function call scopes.

``` elixir
case validate(request) do
  {:ok, request} ->
    case User.fetch(request.user_id) do
      {:ok, user} ->
        # Rinse and repeat
  # Inject the error handling
  {:error, :validation, errors} ->
    render_as_json(errors)
  # ...
end
```

In summary, the `with` macro is a nice abstraction that handles the initial error examples demonstrated by Scott Wlaschin in an elegent and powerful way, as promoted by Elixirs awesome pattern-matching functionality. It "cheats" at the R.O.P concept by providing us an impure-yet-elegent way of composing high-level functions, resulting in a clean and powerful abstraction that gets the job done.

#### References

[Elixir with macro](https://til.hashrocket.com/posts/6a6f5e9fff-elixir-with-macro-and)
[Scott Wlaschin - Railway Oriented Programming](https://vimeo.com/97344498)
[Railway Oriented Programming in Elixir](http://www.zohaib.me/railway-programming-pattern-in-elixir/)
