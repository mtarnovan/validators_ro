defmodule ValidatorsRo do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias __MODULE__.{CIF, CNP, IBAN}

  defdelegate valid_cif?(cif), to: CIF
  defdelegate next_valid_cif(cif), to: CIF
  defdelegate cif_stream(start), to: CIF

  defdelegate valid_cnp?(cnp), to: CNP
  defdelegate parse_cnp(cnp), to: CNP

  defdelegate valid_iban?(iban), to: IBAN
  defdelegate valid_bic?(bic), to: IBAN
end
