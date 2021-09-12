defmodule Twiml.Magic do
  defmacro __using__(_opts) do
    quote do
      require Twiml.Magic
      import Twiml.Magic
    end
  end

  defmacro twiml_verb(name, verb) do
    quote do
      def unquote(name)(verbs \\ nil, content, attrs \\ [])

      # If no content is specified (`""` or `[]`), we will just set an empty
      # content list for XmlBuilder so the XML Tag doesn't have a content body
      # and is closed immediately - e.g. <Hangup/>
      def unquote(name)(nil, content, attrs) when content == [] or content == "" do
        [build_verb(unquote(verb), attrs, [])]
      end

      def unquote(name)(nil, content, attrs) do
        [build_verb(unquote(verb), attrs, content)]
      end

      def unquote(name)(verbs, content, attrs) do
        verbs ++ unquote(name)(nil, content, attrs)
      end

      def unquote(String.to_atom("into_#{name}"))(verbs, attrs, last_n_elements \\ :all) when is_list(attrs) do
        # How many of the preceding xml elements should be put into this one as
        # children? By default :all will be put in.
        case last_n_elements do
          :all ->
            [build_verb(unquote(verb), attrs, [verbs])]

          count when is_integer(count) ->
            {head, tail} = Enum.split(verbs, count)
            head ++ [build_verb(unquote(verb), attrs, [tail])]
        end
      end
    end
  end
end
