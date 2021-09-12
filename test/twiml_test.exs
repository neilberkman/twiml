defmodule TwimlTest do
  use ExUnit.Case
  doctest Twiml

  test "greets the world" do
    assert Twiml.hello() == :world
  end
end
