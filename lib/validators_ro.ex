defmodule ValidatorsRo do
  @moduledoc "README.md"
            |> File.read!()
            |> String.split("<!-- MDOC !-->")
            |> Enum.fetch!(1)

  use ValidatorsRo.IBAN
  use ValidatorsRo.CNP
  use ValidatorsRo.CIF
end
