defmodule TwiML.Magic do
  @moduledoc false

  require Logger
  defmacro __using__(verbs: verbs) do
    quote do
      import TwiML.Magic

      require TwiML.Magic
    end

    for verb <- verbs |> List.flatten() |> Enum.uniq(), do: twiml_verb(verb)
  end

  def twiml_verb(verb) do
    quote do
      twiml = TwiML.Camelize.camelize(Atom.to_string(unquote(verb)))
      Logger.error("TWIML VERB: Processing #{inspect(twiml)}")

      @doc """
      Generates an empty `<#{twiml}>` verb.
      """
      @spec unquote(verb)() :: TwiML.t()
      def unquote(verb)() do
        Logger.error("TWIML MATCH: Empty verb clause")
        [build_verb(unquote(verb), [], [])]
      end

      @doc """
      Generates a `<#{twiml}>` verb.

      There are three supported usages:

      - Wraps `arg` in `<#{twiml}>` if it's `t:TwiML.content/0`.
      - Creates an empty `<#{twiml}>` with attributes for `arg` as a keyword
        list.
      - Appends an empty `<#{twiml}>` to `arg` if it's `t:TwiML.t/0`, enabling
        verb chaining (refer to [Examples](#module-examples)).
      """
      @spec unquote(verb)(TwiML.content() | keyword() | TwiML.t()) :: TwiML.t()
      def unquote(verb)(arg)

      def unquote(verb)(content) when is_binary(content) do
        Logger.error("TWIML MATCH: Binary content clause - content: #{inspect(content)}")
        [build_verb(unquote(verb), [], content)]
      end

      def unquote(verb)({:safe, text} = content) when is_binary(text) do
        Logger.error("TWIML MATCH: Safe text clause - content: #{inspect(content)}")
        [build_verb(unquote(verb), [], content)]
      end

      def unquote(verb)({:cdata, text} = content) when is_binary(text) do
        Logger.error("TWIML MATCH: CDATA clause - content: #{inspect(content)}")
        [build_verb(unquote(verb), [], content)]
      end

      def unquote(verb)({:iodata, text} = content) when is_list(text) do
        Logger.error("TWIML MATCH: IOData clause - content: #{inspect(content)}")
        [build_verb(unquote(verb), [], content)]
      end

      def unquote(verb)(verbs_or_attrs) when is_list(verbs_or_attrs) do
        Logger.error("TWIML MATCH: List clause - verbs_or_attrs: #{inspect(verbs_or_attrs)}")
        if Keyword.keyword?(verbs_or_attrs) do
          Logger.error("TWIML PATH: Keyword list - building single verb")
          [build_verb(unquote(verb), verbs_or_attrs, [])]
        else
          Logger.error("TWIML PATH: Non-keyword list - appending verb")
          verbs_or_attrs ++ [build_verb(unquote(verb), [], [])]
        end
      end

      @doc """
      Appends or generates a `<#{twiml}>` verb.

      There are two supported usages:

      - Appends `<#{twiml}>` to `verbs_or_content` if it's `t:TwiML.t/0`,
        enabling verb chaining (see [Examples](#module-examples)). This verb
        wraps `content_or_attrs` if it's `t:TwiML.content/0`, or includes
        attributes if `content_or_attrs` is a keyword list.
      - Generates `<#{twiml}>` with attributes if `content_or_attrs` is a
        keyword list.
      """
      def unquote(verb)(verbs_or_content, content_or_attrs)

      @spec unquote(verb)(TwiML.t(), keyword() | TwiML.content()) :: TwiML.t()
      def unquote(verb)(verbs, attrs) when is_list(verbs) and is_list(attrs) do
        Logger.error("TWIML MATCH: Two-arg clause with both lists - verbs: #{inspect(verbs)}, attrs: #{inspect(attrs)}")
        verbs ++ [build_verb(unquote(verb), attrs, [])]
      end

      def unquote(verb)(verbs, content) when is_binary(content) do
        Logger.error("TWIML MATCH: Two-arg clause with list+binary - verbs: #{inspect(verbs)}, content: #{inspect(content)}")
        verbs ++ [build_verb(unquote(verb), [], content)]
      end

      @spec unquote(verb)(TwiML.content(), keyword()) :: TwiML.t()
      def unquote(verb)(content, attrs) when is_binary(content) do
        Logger.error("TWIML MATCH: Two-arg clause with binary+attrs - content: #{inspect(content)}, attrs: #{inspect(attrs)}")
        [build_verb(unquote(verb), attrs, content)]
      end

      def unquote(verb)({:safe, text} = content, attrs) when is_binary(text) do
        Logger.error("TWIML MATCH: Two-arg clause with safe text+attrs - content: #{inspect(content)}, attrs: #{inspect(attrs)}")
        [build_verb(unquote(verb), attrs, content)]
      end

      def unquote(verb)({:cdata, text} = content, attrs) when is_binary(text) do
        Logger.error("TWIML MATCH: Two-arg clause with CDATA+attrs - content: #{inspect(content)}, attrs: #{inspect(attrs)}")
        [build_verb(unquote(verb), attrs, content)]
      end

      def unquote(verb)({:iodata, text} = content, attrs) when is_list(text) do
        Logger.error("TWIML MATCH: Two-arg clause with IOData+attrs - content: #{inspect(content)}, attrs: #{inspect(attrs)}")
        [build_verb(unquote(verb), attrs, content)]
      end

      @doc """
      Appends a `<#{twiml}>` verb with attributes.

      Adds a `<#{twiml}>` verb to `verbs` using `attrs` as attributes,
      facilitating verb chaining (see [Examples](#module-examples)).
      """
      @spec unquote(verb)(TwiML.t(), TwiML.content(), keyword()) :: TwiML.t()
      def unquote(verb)(verbs, content, attrs)
          when is_list(verbs) and is_binary(content) and is_list(attrs) do
        Logger.error("TWIML MATCH: Three-arg clause - verbs: #{inspect(verbs)}, content: #{inspect(content)}, attrs: #{inspect(attrs)}")
        verbs ++ [build_verb(unquote(verb), attrs, content)]
      end
    end
  end
end
