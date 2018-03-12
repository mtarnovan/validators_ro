defmodule ValidatorsRo.CNP do
  @moduledoc """
  See `ValidatorsRo`
  """

  defmacro __using__(_opts) do
    quote location: :keep do
      import ValidatorsRo.Utils, only: [control_sum: 2]
      require Integer

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
      @cnp_county_map %{
        "01" =>	"Alba",
        "02" =>	"Arad",
        "03" =>	"Argeș",
        "04" =>	"Bacău",
        "05" =>	"Bihor",
        "06" =>	"Bistrița-Năsăud",
        "07" =>	"Botoșani",
        "08" =>	"Brașov",
        "09" =>	"Brăila",
        "10" =>	"Buzău",
        "11" =>	"Caraș-Severin",
        "12" =>	"Cluj",
        "13" =>	"Constanța",
        "14" =>	"Covasna",
        "15" =>	"Dâmbovița",
        "16" =>	"Dolj",
        "17" =>	"Galați",
        "18" =>	"Gorj",
        "19" =>	"Harghita",
        "20" =>	"Hunedoara",
        "21" =>	"Ialomița",
        "22" =>	"Iași",
        "23" =>	"Ilfov",
        "24" =>	"Maramureș",
        "25" =>	"Mehedinți",
        "26" =>	"Mureș",
        "27" =>	"Neamț",
        "28" =>	"Olt",
        "29" =>	"Prahova",
        "30" =>	"Satu Mare",
        "31" =>	"Sălaj",
        "32" =>	"Sibiu",
        "33" =>	"Suceava",
        "34" =>	"Teleorman",
        "35" =>	"Timiș",
        "36" =>	"Tulcea",
        "37" =>	"Vaslui",
        "38" =>	"Vâlcea",
        "39" =>	"Vrancea",
        "40" =>	"București",
        "41" =>	"București Sectorul 1",
        "42" =>	"București Sectorul 2",
        "43" =>	"București Sectorul 3",
        "44" =>	"București Sectorul 4",
        "45" =>	"București Sectorul 5",
        "46" =>	"București Sectorul 6",
        "51" =>	"Călărași",
        "52" =>	"Giurgiu"
      }

      @doc """
      Provides validation of Romanian CNPs (equivalent of SSNs)

      https://ro.wikipedia.org/wiki/Cod_numeric_personal
      """
      @spec valid_cnp?(String.t) :: boolean
      def valid_cnp?(cnp) do
        cnp_well_formed?(cnp) && cnp_valid_control_sum?(cnp)
      end

      @doc """
      Parses a CNP into a map of parts, with the following keys:
        * `:valid` (boolean)
        * `:sex`, a string of either "male" or "female"
        * `:date_of_birth`, as a string representation in ISO8601 format (YYYY-MM-DD)
        * `:county of birth` - a string representing the Romanian name of
        the county of birth. `nil` if `:foreign` is true
        * `:per_county_index` - a numeric string between 001 - 999, see Wikipedia entry for details
        * `:control` - a single digit control
        * `:foreign` (boolean), indicating person is a foreign national

      For invalid CNPs, no parsing is attempted and only `:valid` is returned.
      """
      @spec parse_cnp(String.t) :: map
      def parse_cnp(cnp) when is_bitstring(cnp) do
        parsed =
          if valid = valid_cnp?(cnp) do
            <<sex_code::bytes-size(1)>> <>
              <<dob_year::bytes-size(2)>> <>
              <<dob_month::bytes-size(2)>> <>
              <<dob_day::bytes-size(2)>> <>
              <<county_of_birth_code::bytes-size(2)>> <>
              <<county_index::bytes-size(3)>> <>
              <<control::bytes-size(1)>> = cnp

            sex_code = sex_code |> String.to_integer()
            sex = if Integer.is_odd(sex_code) do "male" else "female" end

            foreign = sex_code in [7, 8]

            date_of_birth =
              case sex_code do
                n when n in [1, 2, 7, 8] -> "19#{dob_year}-#{dob_month}-#{dob_day}"
                n when n in [3, 4] -> "18#{dob_year}-#{dob_month}-#{dob_day}"
                n when n in [5, 6] -> "20#{dob_year}-#{dob_month}-#{dob_day}"
              end
            %{
              sex: sex,
              date_of_birth: date_of_birth,
              county_of_birth_code: county_of_birth_code,
              county_of_birth: @cnp_county_map[county_of_birth_code],
              county_index: county_index,
              control: control,
              foreign: foreign
            }
          else
            %{}
          end

        Map.put(parsed, :valid, valid)
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
    end
  end
end
