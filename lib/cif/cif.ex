defmodule ValidatorsRo.CIF do
  @moduledoc """
  See `ValidatorsRo`
  """
  import ValidatorsRo.Utils, only: [control_sum: 2]

  defmacro __using__(_opts) do
    quote location: :keep do

      @cif_test_key 753217532
      |> Integer.digits
      |> Enum.reverse

      @doc """
      Provides validation of Romanian CIFs
      (cod de identificare fiscala - fiscal identification code).

      https://ro.wikipedia.org/wiki/Cod_de_Identificare_Fiscal%C4%83
      """
      @spec valid_cif?(String.t) :: boolean
      def valid_cif?(cif) when is_bitstring(cif) do
        cif_well_formed?(cif) && cif_valid_control_sum?(cif)
      end

      @spec valid_cif?(cif :: integer) :: boolean
      def valid_cif?(cif) when is_integer(cif) do
        valid_cif?(cif |> to_string)
      end

      @doc """
      Given an integer (or a string representation of one),
      returns the next highest valid CIF
      """
      @spec next_valid_cif(int :: String.t) :: integer
      def next_valid_cif(int) when is_bitstring(int) do
        next_valid_cif(int |> String.to_integer)
      end

      @spec next_valid_cif(int :: integer) :: integer
      def next_valid_cif(int) when is_integer(int) do
        {control, sum} = control_sum(int |> to_string, @cif_test_key)
        last_digit_of_next_cif =
          sum
            |> Kernel.*(10)
            |> rem(11)
            |> rem(10)

        if last_digit_of_next_cif < control do
          next_valid_cif((div(int, 10) + 1) * 10)
        else
          replace_last_digit(int, last_digit_of_next_cif)
        end
      end

      @doc """
      Returns a `Stream` of valid CIFs, starting at `start` (defaults to `1` if missing)

      Example:
      ```
      iex> ValidatorsRo.cif_stream(10_000) |> Enum.take(10)
      [10004, 10012, 10020, 10039, 10047, 10055, 10063, 10071, 10080, 10098]
      ```
      """
      @spec cif_stream(start :: integer) :: integer
      def cif_stream(start \\ 1)
      def cif_stream(start) when (is_integer(start) and start < 1) do
        cif_stream(1)
      end

      @spec cif_stream(start :: integer) :: integer
      def cif_stream(start) when is_integer(start) and start >= 1 do
        Stream.unfold start, fn cif ->
          next = next_valid_cif(cif)
          {next, next + 1}
        end
      end

      @doc false
      defp cif_well_formed?(cif) do
        Regex.match?(~r/^\d{2,10}$/, cif)
      end

      @doc false
      defp cif_valid_control_sum?(cif) do
        {control, sum} = control_sum(cif, @cif_test_key)
        sum
          |> Kernel.*(10)
          |> rem(11)
          |> rem(10)
          |> Kernel.===(control)
      end

      @doc false
      defp replace_last_digit(number, digit) when is_bitstring(number) do
        replace_last_digit(number |> String.to_integer, digit)
      end

      @doc false
      defp replace_last_digit(number, digit) when is_integer(number) do
        (Integer.to_charlist(div(number, 10))) ++ to_charlist(digit) |> to_string |> String.to_integer
      end
    end
  end
end
