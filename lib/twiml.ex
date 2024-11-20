defmodule TwiML do
  require Logger
  @moduledoc """
  Generate complex TwiML documents for Twilio in an elegant Elixir way.

  > #### Note {: .warning}
  >
  > Please refer to the [official TwiML
  > documentation](https://www.twilio.com/docs/voice/twiml) to verify that the
  > TwiML verb actually supports content or the given attributes.

  #{"README.md" |> File.read!() |> String.split("<!-- MDOC !-->") |> Enum.fetch!(1)}
  """

  # The nesting and duplication is intentionally as it improves comparing the
  # verbs with the official TwiML at https://www.twilio.com/docs/voice/twiml
  use TwiML.Magic,
    verbs: [
      [:connect, :autopilot, :siprec, :stream, :virtual_agent],
      [
        :dial,
        :application,
        :client,
        [:identity, :parameter],
        :conference,
        :number,
        :queue,
        :sim,
        :sip
      ],
      :enqueue,
      :gather,
      :hangup,
      :leave,
      :pause,
      [:pay, :prompt, :parameter],
      :play,
      :record,
      :redirect,
      :refer,
      :reject,
      :say,
      :siprec,
      :stream
    ]

  import TwiML.Camelize, only: [camelize: 2]

  @external_resource "README.md"

  @typedoc """
  A TwiML document contains one or more TwiML verbs. These verbs can have
  attributes and can wrap nested TwiML verbs.
  """
  @type t :: [{atom(), keyword(), content() | t()}]

  @typedoc """
  Content which can be used within a TwiML verb. Refer to the `XmlBuilder`
  documentation for more information.
  """
  @type content :: binary() | {:safe, binary()} | {:cdata, binary()} | {:iodata, binary()}

  @doc """
  Generates a XML document from the provided verbs and arguments. For the
  supported `opts`, please refer to the documentation of
  `XmlBuilder.generate/2`.

  ## Examples

      iex> TwiML.say("Hello world")
      ...> |> TwiML.to_xml(format: :none)
      ~s(<?xml version="1.0" encoding="UTF-8"?><Response><Say>Hello world</Say></Response>)

  """
  @doc helper: true
  def to_xml(verbs, opts \\ []) do
    :Response
    |> XmlBuilder.document(verbs)
    |> XmlBuilder.generate(opts)
  end

  defp build_verb(verb, attrs, children) do
    Logger.error("""
    BUILD VERB START:
    Verb: #{inspect(verb)}
    Raw attrs: #{inspect(attrs)}
    Children pre-process: #{inspect(children)}
    """)

    verb_string = Atom.to_string(verb)
    Logger.error("After Atom.to_string: #{inspect(verb_string)}")

    capitalized = String.capitalize(verb_string)
    Logger.error("After capitalize: #{inspect(capitalized)}")

    processed_attrs =
      try do
        attrs
        |> tap(&Logger.error("Processing attrs: #{inspect(&1)}"))
        |> Enum.reject(&is_nil(elem(&1, 1)))
        |> tap(&Logger.error("After reject nil: #{inspect(&1)}"))
        |> Enum.map(fn {k, v} ->
          Logger.error("Processing key: #{inspect(k)} with value: #{inspect(v)}")
          processed = camelize(k, :lower)
          Logger.error("Camelized key: #{inspect(processed)}")
          {processed, v}
        end)
        |> tap(&Logger.error("Final processed attrs: #{inspect(&1)}"))
      rescue
        e ->
          Logger.error("Error processing attributes: #{inspect(e)}")
          reraise e, __STACKTRACE__
      end

    Logger.error("""
    BUILD VERB END:
    Final verb: #{inspect(capitalized)}
    Final attrs: #{inspect(processed_attrs)}
    Final children: #{inspect(children)}
    """)

    {capitalized, processed_attrs, children}
  end

  @doc """
  Generates a comment.

  ## Examples

      iex> TwiML.comment("Blocked because of insufficient funds")
      ...> |> TwiML.to_xml(format: :none)
      ~s(<?xml version="1.0" encoding="UTF-8"?><Response><!-->Blocked because of insufficient funds</!--></Response>)

  """
  @doc helper: true
  def comment(text) do
    [{"!--", [], text}]
  end

  @doc """
  Appends a comment to the TwiML.

  ## Examples

      iex> TwiML.reject() |> TwiML.comment("Blocked because of insufficient funds") |> TwiML.to_xml(format: :none)
      ~s(<?xml version="1.0" encoding="UTF-8"?><Response><Reject/><!-->Blocked because of insufficient funds</!--></Response>)

  """
  @doc helper: true
  def comment(verbs, text) do
    verbs ++ [comment(text)]
  end
end
