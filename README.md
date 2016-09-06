# Validators for Romanian CIF, CNP and IBAN

## Description

Extracted from [openapi.ro](https://beta.openapi.ro),
a collection of APIs for Romanian developers.

* CNP https://ro.wikipedia.org/wiki/Cod_numeric_personal
* CIF https://ro.wikipedia.org/wiki/Cod_de_Identificare_Fiscal%C4%83
* IBAN http://www.bnr.ro/files/d/Legislatie/EN/Reg_IBAN.pdf

Please note that IBAN validation is implemented per BNR
specification and might not work for international IBANs.

## Installation

Add `validators_ro` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:validators_ro, "~> 1.0.0"}]
end
```

## Usage

All validators expect strings as input.

```elixir
ValidatorsRo.valid_cif?("13548146")
ValidatorsRo.valid_cnp?("1920822296090")
ValidatorsRo.valid_iban?("RO56TREZ0462107020101XXX")
```

### LICENSE

MIT LICENSE. See LICENSE for details.