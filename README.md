# Validators for Romanian CIF, CNP and IBAN

<!-- MDOC !-->

An [Elixir](https://elixir-lang.org/) collection of validators
and utilities around Romanian identifiers, extracted from [openapi.ro](https://openapi.ro),
business APIs for Romanian developers.

* CNP https://ro.wikipedia.org/wiki/Cod_numeric_personal (roughly equivalent of American SSN)
* CIF https://ro.wikipedia.org/wiki/Cod_de_Identificare_Fiscal%C4%83 (roughly equivalent of American EIN)
* IBAN http://www.bnr.ro/files/d/Legislatie/EN/Reg_IBAN.pdf

Please note that IBAN validation is implemented per BNR
specification and might not work for international IBANs.

For each identifier a `valid_#{identifier}?` function is provided.

Additionaly:
  * an infinite stream of valid CIFs is provided by `cif_stream/1`.
  * `parse_cnp/1` allows parsing a valid CNP into constituent parts

## Examples
```elixir
iex> import ValidatorsRo
iex> valid_cif?("13548146")
true
iex> valid_cnp?("1920822296090")
true
iex> parse_cnp("1920822296090")
%{control: "0", county_index: "609", county_of_birth: "Prahova",
  county_of_birth_code: "29", date_of_birth: "1992-08-22", foreign: false,
  sex: "male", valid: true}
iex> valid_iban?("RO56TREZ0462107020101XXX")
true
iex> valid_bic?("RZTIAT22263")
true
iex> cif_stream(10_000) |> Enum.take(10)
[10004, 10012, 10020, 10039, 10047, 10055, 10063, 10071, 10080, 10098]
```
<!-- MDOC !-->

## Installation

Add `validators_ro` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:validators_ro, git: "https://github.com/mtarnovan/validators_ro.git"}
  ]
end

(Not published as a Hex package yet).
```

### LICENSE

MIT LICENSE. See LICENSE for details.