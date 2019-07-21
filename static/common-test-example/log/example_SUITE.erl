-module(example_SUITE). % The naming convention (with uppercase _SUITE) Erlang
                        % convention which allow ct to find test suites.
                        % Something like ExUnit _test.exs naming convention

-export([all/0]).

-export([test_function_name/1]).

all() ->
    [test_function_name].

test_function_name(_Config) ->
    ct:log("Example message"),
    2 = 1 + 1.
