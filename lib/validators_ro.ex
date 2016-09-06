defmodule ValidatorsRo do
  @moduledoc """
  Provides validators for:
  * Cod Numeric Personal (CNP) - Romanian SSN
  * Cod de identificare fiscală (CIF) and
  * IBAN (only Romanian format as published by Romanian National Bank).
  * BIC
  """

  @cif_test_key 753217532
    |> Integer.digits
    |> Enum.reverse

  @cnp_test_key 279146358279
    |> Integer.digits
    |> Enum.reverse
  @cnp_regexp ~r"^\d{13}$"
  @cnp_century_map  %{ # Maps first number of CNP to century of birthdate
    "1" => "19",
    "2" => "19",
    "3" => "18",
    "4" => "18",
    "5" => "20",
    "6" => "20"
  }

  @bic_regexp ~r"([a-zA-Z]){4}([a-zA-Z]){2}([0-9a-zA-Z]){2}([0-9a-zA-Z]{3})?$"

  @doc """
  Provides validation of Romanian CIFs
  (cod de identificare fiscala - fiscal identification code).

  https://ro.wikipedia.org/wiki/Cod_de_Identificare_Fiscal%C4%83
  """
  @spec valid_cif?(String.t) :: boolean
  def valid_cif?(cif) do
    cif_well_formed?(cif) && cif_valid_control_sum?(cif)
  end

  @doc """
  Provides validation of Romanian CNPs (equivalent of SSNs)

  https://ro.wikipedia.org/wiki/Cod_numeric_personal
  """
  @spec valid_cnp?(String.t) :: boolean
  def valid_cnp?(cnp) do
    cnp_well_formed?(cnp) && cnp_valid_control_sum?(cnp)
  end


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

  defp cif_well_formed?(cif) do
    Regex.match?(~r/^\d{2,10}$/, cif)
  end

  defp cif_valid_control_sum?(cif) do
    {control, sum} = control_sum(cif, @cif_test_key)
    sum
      |> Kernel.*(10)
      |> rem(11)
      |> rem(10)
      |> Kernel.===(control)
  end

  defp cnp_well_formed?(cnp) do
    Regex.match?(@cnp_regexp, cnp) && valid_birthdate?(cnp)
  end

  defp cnp_valid_control_sum?(cnp) do
    {control, sum} = control_sum(cnp, @cnp_test_key)
    case rem(sum, 11) do
      10 -> control === 1
      rest -> control === rest
    end
  end

  defp valid_birthdate?(cnp) do
    century = Map.get(@cnp_century_map, String.at(cnp, 0), :guess)
    year = century <> String.slice(cnp, 1, 2)
    month = cnp |> String.slice(3, 2)
    day = cnp |> String.slice(5, 2)

    # For foreign nationals the first number of the CNP doesn't map
    # to birthday century, so we try all recent centuries
    case century do
      :guess ->
        @cnp_century_map
          |> Map.values
          |> Enum.uniq
          |> Enum.any?(&(valid_birthdate?(&1 <> month, month, day)))
      _ -> valid_birthdate?(year, month, day)
    end
  end

  defp valid_birthdate?(year, month, day) do
    case Date.from_iso8601("#{year}-#{month}-#{day}") do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  defp control_sum(n, test_key) do
    {numbers, _} = Integer.parse(n)
    [control | rest_digits] = numbers
      |> Integer.digits
      |> Enum.reverse
    sum = rest_digits
        |> Enum.zip(test_key)
        |> Enum.map(fn {a, b} -> a * b end)
        |> Enum.sum
    {control, sum}
  end

  defp transpose(iban) do
    Regex.replace ~r/[A-Z]/, String.upcase(iban), fn x ->
      x
        |> String.to_char_list
        |> hd
        |> Kernel.-(55)
        |> to_string
    end
  end
end
