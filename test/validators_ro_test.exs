defmodule ValidatorsRoTest do
  use ExUnit.Case
  doctest ValidatorsRo
  import ValidatorsRo

  @valid_cifs File.stream!("test/data/valid_cifs.txt")
  @invalid_cifs File.stream!("test/data/invalid_cifs.txt")

  @valid_cnps File.stream!("test/data/valid_cnps.txt")
  @invalid_cnps ~w(123456789 12 0 111111 1234567891234)

  @valid_ibans File.stream!("test/data/valid_ibans.txt")
  @invalid_ibans ~w(foo 123 999 ROBTRLSTUFFFOO)

  @valid_bics File.stream!("test/data/valid_bics.txt")
  @invalid_bics File.stream!("test/data/invalid_bics.txt")

  test "valid CIFs" do
    assert @valid_cifs |> Enum.all?(&(valid_cif? &1))
  end
  test "invalid CIFs" do
    assert @invalid_cifs |> Enum.all?(&(!valid_cif? &1))
  end

  test "valid CNPs" do
    assert @valid_cnps |> Enum.all?(&(valid_cnp? &1))
  end
  test "invalid CNPs" do
    assert @invalid_cnps |> Enum.all?(&(!valid_cnp? &1))
  end

  test "valid IBANs" do
    assert @valid_ibans |> Enum.all?(&(valid_iban? &1))
  end
  test "invalid IBANs" do
    assert @invalid_ibans |> Enum.all?(&(!valid_iban? &1))
  end

  test "invalid BICs" do
    assert @invalid_bics |> Enum.all?(&(!valid_bic? &1))
  end
  test "valid BICs" do
    assert @valid_bics |> Enum.all?(&(valid_bic? &1))
  end
end
