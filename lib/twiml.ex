defmodule TwiML do
  @moduledoc """
  Generate complex TwiML responses for Twilio in an elegant Elixir way.

  ## Examples:

  Say 2 things, one after the other:

      iex> TwiML.say("Hello") |> TwiML.say("world") |> TwiML.to_xml()
      ~s(<Response>
        <Say>Hello</Say>
        <Say>world</Say>
      </Response>)

  Say something in another voice:

      iex> TwiML.say(nil, "Hello", voice: "woman") |> TwiML.to_xml()
      ~s(<Response>
        <Say voice="woman">Hello</Say>
      </Response>)

  Leaving the content empty for a TwiML verb, will create a XML Element that has no body:

      iex> TwiML.hangup([]) |> TwiML.to_xml()
      ~s(<Response>
        <Hangup/>
      </Response>)

  You can embed TwiML tags into other tags using the into_<verb> function:

      iex> TwiML.say("Lets say this inside the gather")
      ...> |> TwiML.into_gather(language: "en-US", input: "speech")
      ...> |> TwiML.to_xml()
      ~s(<Response>
        <Gather language="en-US" input="speech">
          <Say>Lets say this inside the gather</Say>
        </Gather>
      </Response>)

  If you have multiple TwiML tags you want to embed, that works too:

      iex> TwiML.say("Hi")
      ...> |> TwiML.say("We cool?")
      ...> |> TwiML.into_gather(language: "en-US", input: "speech", hints: "yes, no")
      ...> |> TwiML.to_xml()
      ~s(<Response>
        <Gather language="en-US" input="speech" hints="yes, no">
          <Say>Hi</Say>
          <Say>We cool?</Say>
        </Gather>
      </Response>)

  It is also possible to just include a few of the preceding tags into the body of another element.
  The `1` decides that we want to only put the last element into the Dial element's body:

      iex> TwiML.say("Outside")
      ...> |> TwiML.number("+0800-inside")
      ...> |> TwiML.into_dial([], 1)
      ...> |> TwiML.to_xml()
      ~s(<Response>
        <Say>Outside</Say>
        <Dial>
          <Number>+0800-inside</Number>
        </Dial>
      </Response>)
  """
  use TwiML.Magic,
    verbs: [
      :dial,
      :gather,
      :hangup,
      :number,
      :pause,
      :play,
      :say
    ]

  def to_xml(verbs) do
    {:Response, [], verbs}
    |> XmlBuilder.generate()
  end


  defp build_verb(verb, attrs, children) do
    verb = verb |> Atom.to_string() |> String.capitalize()
    {verb, attrs, children}
  end
end
