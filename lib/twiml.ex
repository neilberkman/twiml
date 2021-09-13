defmodule TwiML do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

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
