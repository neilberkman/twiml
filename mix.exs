defmodule Twiml.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :twiml,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [extras: ["README.md"], main: "readme", source_ref: "v#{@version}"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:xml_builder, "~> 2.2"},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end
end
