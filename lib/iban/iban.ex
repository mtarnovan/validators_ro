defmodule ValidatorsRo.IBAN do
  @moduledoc """
  See `ValidatorsRo`
  """
  defmacro __using__(_opts) do
    quote location: :keep do
      @bic_regexp ~r"([a-zA-Z]){4}([a-zA-Z]){2}([0-9a-zA-Z]){2}([0-9a-zA-Z]{3})?$"

      @doc """
      Provides basic validation of *Romanian* IBANs

      http://www.bnr.ro/files/d/Legislatie/EN/Reg_IBAN.pdf
      """
      @spec valid_iban?(String.t) :: boolean
      def valid_iban?(iban) do
        {t, h} =
          iban
            |> String.trim
            |> String.split_at(4)
        n = transpose(h <> t)
        case Integer.parse(n) do
          {n, ""} -> rem(n, 97) === 1
          _ -> false
        end
      end

      @doc """
      Provides basic validation of BICs

      https://en.wikipedia.org/wiki/ISO_9362
      """
      @spec valid_bic?(String.t) :: boolean
      def valid_bic?(bic) do
        Regex.match?(@bic_regexp, bic)
      end

      defp transpose(iban) do
        Regex.replace ~r/[A-Z]/, String.upcase(iban), fn x ->
          x
            |> String.to_charlist
            |> hd
            |> Kernel.-(55)
            |> to_string
        end
      end
    end
  end
end
