defmodule Twiml do
  use Twiml.Magic

  @moduledoc """
  Generate complex Twilio responses in a single pipeline.

  ## Examples:

  Say 2 things, one after the other:

      iex> Twiml.say("Hello") |> Twiml.say("world") |> Twiml.to_xml()
      ~s(<Response>
        <Say>Hello</Say>
        <Say>world</Say>
      </Response>)

  Say something in another voice:

      iex> Twiml.say(nil, "Hello", voice: "woman") |> Twiml.to_xml()
      ~s(<Response>
        <Say voice="woman">Hello</Say>
      </Response>)

  Leaving the content empty for a Twiml verb, will create a XML Element that has no body:

      iex> Twiml.hangup([]) |> Twiml.to_xml()
      ~s(<Response>
        <Hangup/>
      </Response>)

  You can embed Twiml tags into other tags using the into_<verb> function:

      iex> Twiml.say("Lets say this inside the gather")
      ...> |> Twiml.into_gather(language: "en-US", input: "speech")
      ...> |> Twiml.to_xml()
      ~s(<Response>
        <Gather language="en-US" input="speech">
          <Say>Lets say this inside the gather</Say>
        </Gather>
      </Response>)

  If you have multiple Twiml tags you want to embed, that works too:

      iex> Twiml.say("Hi")
      ...> |> Twiml.say("We cool?")
      ...> |> Twiml.into_gather(language: "en-US", input: "speech", hints: "yes, no")
      ...> |> Twiml.to_xml()
      ~s(<Response>
        <Gather language="en-US" input="speech" hints="yes, no">
          <Say>Hi</Say>
          <Say>We cool?</Say>
        </Gather>
      </Response>)

  It is also possible to just include a few of the preceding tags into the body of another element.
  The `1` decides that we want to only put the last element into the Dial element's body:

      iex> Twiml.say("Outside")
      ...> |> Twiml.number("+0800-inside")
      ...> |> Twiml.into_dial([], 1)
      ...> |> Twiml.to_xml()
      ~s(<Response>
        <Say>Outside</Say>
        <Dial>
          <Number>+0800-inside</Number>
        </Dial>
      </Response>)
  """

  twiml_verb(:play, :Play)
  twiml_verb(:dial, :Dial)
  twiml_verb(:number, :Number)
  twiml_verb(:say, :Say)
  twiml_verb(:pause, :Pause)
  twiml_verb(:gather, :Gather)
  twiml_verb(:hangup, :Hangup)

  defp build_verb(verb, attrs, children) do
    {verb, attrs, children}
  end

  def to_xml(verbs) do
    {:Response, [], verbs}
    |> XmlBuilder.generate()
  end
end
