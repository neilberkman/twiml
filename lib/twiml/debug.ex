defmodule TwiML.Debug do
  require Logger

  def log_attrs(verb, attrs) do
    Logger.debug("""
    TwiML #{verb} attributes:
    Before processing: #{inspect(attrs)}
    After camelize: #{inspect(
      attrs
      |> Enum.reject(&is_nil(elem(&1, 1)))
      |> Enum.map(fn {k, v} -> {TwiML.Camelize.camelize(k, :lower), v} end)
    )}
    """)
  end
end
