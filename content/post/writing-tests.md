+++
date = 2026-05-13
title = "How do I write Elixir tests?"

description = """
Personal guides for writing tests that are readable and maintainable. Stuff to
use, stuff to avoid, and how to organize stuff.

Furthermore, I think that mocking must be destroyed.
"""

[taxonomies]
tags = [
    "beam",
    "testing"
]
+++

I created this post for myself to codify some basic guides that I use while
writing tests. If you, my dear reader, want to read this, then remember one
important thing:

These are **guides** not *rules*. Each codebase is different and exceptions are
expected and *will* happen. Just use the thing between your ears in your coding.

## `@subject` module attribute for module under test

While reading ExUnit test, I often find it hard to remember which of the used
modules is tested. Imagine test like:

```elixir
test "foo should frobnicate when bar" do
  bar = pick_bar()

  assert :ok == MyBehaviour.foo(MyImplementation, bar)
end
```

It is not obvious at the first sight what is tested here. And this is pretty
simplified example. In real world it can became even harder to notice what is
module under test (MUT).

To resolve that I came up with a simple solution. I create module attribute
named `@subject` that points to the MUT:

```elixir
@subject MyImplementation

test "foo should frobnicate when bar" do
  bar = pick_bar()

  assert :ok == MyBehaviour.foo(@subject, bar)
end
```

Now it is more obvious what is MUT and what is just wrapper code around it.

In the past I have been using `alias` with `:as` option, like:

```elixir
alias MyImplementation, as: Subject
```

However, I find module attribute to be more visually distinctive, which make it
easier for me to notice `@subject` than `Subject`. But your mileage may vary.

## `describe` with function name

That one is pretty basic. I have seen that it is pretty standard for people:
when you are writing tests for module functions, then group them in `describe`
blocks that will contain name (and arity) of the function in the name. Example:

```elixir
# Module under test
defmodule Foo do
  def a(x, y, z) do
    # some code
  end
end

# Tests
defmodule FooTest do
  use ExUnit.Case, async: true

  @subject Foo

  describe "a/3" do
    # Some tests here
  end
end
```

This allows me to see what functionality I am testing.

Of course that doesn't apply to the Phoenix controllers, as there we do not test
functions, but tuples in form `{method, path}` which I then write as `METHOD
path`, for example `POST /users`. But the idea still stands - `describe` block
provide immediate context about what is tested.

## Avoid module mocking

In Elixir we have bunch of the mocking libraries out there, but most of them
have quite substantial issue for me - these prevent me from using `async: true`
for my tests. This often causes substantial performance hit, as it prevents
different modules to run in parallel (not single tests, *modules*, but that is
probably material for another post).

Instead of mocks I prefer to utilise dependency injection. Some people may argue
that "Elixir is FP, not OOP, there is no need for dependency injection". They
could not be further from truth. DI isn't related to OOP, it just have different
form - function arguments. For example, if we want to have function that do
something with time, in particular - current time, then instead of writing:

```elixir
def my_function(a, b) do
  do_foo(a, b, DateTime.utc_now())
end
```

Which would require me to use mocks for `DateTime` or other workarounds to make
tests time-independent. I would do:

```elixir
def my_function(a, b, now \\ DateTime.utc_now()) do
  do_foo(a, b, now)
end
```

Which still provide me the ergonomics of `my_function/2` as above, but is way
easier to test, as I can pass the date to the function itself. Now I can run
this test in parallel as it will not cause other tests to do weird stuff because
of altered `DateTime` behaviour.

This approach I use a lot when I am writing some functions that are doing
HTTP(S) requests to external services. I use optional[^opt-arg] keyword list
argument called with super creative name `opts`. With that, I can pass option
like `:host` which allows me to use tools like [`test_server`][] which is great
and it is, in my humble opinion, way better approach than any mocking.

[^opt-arg]: Arguments in Elixir never are optional, it is a clever trick from
    language authors, but that is probably for another article.

[`test_server`]: https://github.com/danschultzer/test_server

## Avoid `ex_machina` factories

I have poor experience with tools like `ex_machina` or similar. These often
bring whole [Banana Gorilla Jungle problem][bgj] back, just changed a little, as
now instead of just passing data around, we create all needless structures for
sole purpose of test, even when they aren't needed for anything.

[bgj]: https://softwareengineering.stackexchange.com/q/368797

Start with example from [ExMachina README](https://github.com/beam-community/ex_machina#overview):

```elixir
defmodule MyApp.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: MyApp.Repo

  # without Ecto
  use ExMachina

  def user_factory do
    %MyApp.User{
      name: "Jane Smith",
      email: sequence(:email, &"email-#{&1}@example.com"),
      role: sequence(:role, ["admin", "user", "other"]),
    }
  end

  def article_factory do
    title = sequence(:title, &"Use ExMachina! (Part #{&1})")
    # derived attribute
    slug = MyApp.Article.title_to_slug(title)
    %MyApp.Article{
      title: title,
      slug: slug,
      # associations are inserted when you call `insert`
      author: build(:user),
    }
  end

  # derived factory
  def featured_article_factory do
    struct!(
      article_factory(),
      %{
        featured: true,
      }
    )
  end

  def comment_factory do
    %MyApp.Comment{
      text: "It's great!",
      article: build(:article),
      author: build(:user)
    }
  end
end
```

For start we can see a single problem there - we do not validate our factories
against our schema changesets. Without additional tests like:

```elixir
@subject MyApp.Article

test "factory conforms to changeset" do
  changeset = @subject.changeset(%@subject{}, params_for(:article))

  assert changeset.valid?
end
```

We cannot be sure that our tests test what we want them to test. And if we pass
custom attribute values in some tests it gets even worse, because we cannot be
sure if these are conforming either.

That mean that our tests may be moot, because we aren't testing against real
situations, but against some predefined state.

Another problem is that if we need to alter the behaviour of the factory it can
became quite convoluted. Imagine situation when we want to test if comments by
author of the post have some special behaviour (for example it has some
additional CSS class to be able to mark them in CSS). That require from us to do
some dancing around passing custom attributes:

```elixir
test "comments by author are special" do
  post = insert(:post)
  comment = insert(:comment, post: post, author: post.author)

  # rest of the test
end
```

And this is simplified example. In the past I needed to deal with situations
where I was creating a lot of data to pass through custom attributes to make
test sensible.

Instead, I prefer to do stuff directly in code. Instead of relying on some
"magical" functions provided by some "magical" macros from external library I
can use what I already have - functions in my application.

Instead of:

```elixir
test "comments by author are special" do
  post = insert(:post)
  comment = insert(:comment, post: post, author: post.author)

  # rest of the test
end
```

Write:

```elixir
test "comments by author are special" do
  author = MyApp.Users.create(%{
      name: "John Doe",
      email: "john@example.com"
    })
  post = MyApp.Blog.create_article(%{
      author: author,
      content: "Foo bar",
      title: "Foo bar"
    })
  comment = MyApp.Blog.create_comment_for(article, %{
      author: author,
      content: "Foo bar"
    })

  # rest of the test
end
```

It may be a little bit more verbose, but it makes tests way more readable in my
opinion. You have all details just in place and you know what to expect. And if
you need some piece of data in all (or almost all) tests within
module/`describe` block, then you can always can use `setup/1` blocks.
Alternatively, you can create function per module that will generate data for
you. As long as your test module is self-contained and do not receive "magical"
data out of thin air, it is okay for me. But `ex_machina` is, in my opinion,
terrible idea brought from Rails world, that make little to no sense in Elixir.

If you *really* need such factories, then just write your own functions that will
use your contexts instead of relying on another library. For example:

```elixir
import ExUnit.Assertions

def create_user(name, email \\ nil, attrs \\ %{}) do
  email = email || "#{String.replace(name, " ", ".")}@example.com"
  attrs = Map.merge(attrs, %{name: name, email: email})

  assert {:ok, user} = MyApp.Users.create(attrs)

  user
end

# And so on…
```

This way you do not need to check if all tests use correct validations any
longer, as your system will do that for you. No more surprises related to
dealing with "impossible data".

## Property testing is awesome

[Property based Testing][PBT] is absurdly wide topic, and this article isn't a
place to describe all possibilities of that approach. There are [books][pbt-erl]
written about this topic. However, it is something I find useful to keep in mind,
that this approach exists and is tremendously useful in many places (not all, do
not try to squeeze square peg into round hole).

Quick example that I can show is:

```elixir
property "valid names starts with alphanumeric and are composed of alphanumeric, underscore, and dash" do
  check all(
          prefix <- string(:alphanumeric, length: 1),
          suffix <- string([?a..?z, ?A..?Z, ?-, ?_], max_length: 24)
        ) do
    changeset =
      @subject.register_changeset(%@subject{}, %{name: prefix <> suffix})

    assert nil == changeset.errors[:name]
  end
end
```

It checks whether all usernames, that start with alphanumeric character and is
followed by sequence of up to 24 characters containing alphanumeric characters
with addition of dash and underscore, pass through validation.

This test will try to generate *random* set of possible usernames, and then
check if all of them pass the test. If something fails, then system will try to
reduce found example to create minimal example that fails. It is not fully
deterministic test (the output may depend on randomly selected seed), but if
used correctly with other tests, it will greatly improve confidence in tests.

## Parting words

Tests should be readable, often even more readable than the code itself. Good
test suite can help you with confidence in your changes. In current world, full
of agentic coding, tests became even more important, as with good tests suite
you can give your agents more autonomy.

Furthermore, I think that mocking must be destroyed.

[PBT]: https://en.wikipedia.org/wiki/Property_testing
[pbt-erl]: https://propertesting.com
[claude-cc]: https://www.anthropic.com/engineering/building-c-compiler
