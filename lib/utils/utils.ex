defmodule ValidatorsRo.Utils do
  @moduledoc false

  @doc false
  def control_sum(n, test_key) do
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
end
