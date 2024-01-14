defmodule ValidatorsRo.Mixfile do
  use Mix.Project

  def project do
    [
      app: :validators_ro,
      version: "1.0.0",
      elixir: "~> 1.3",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ValidatorsRo",
      docs: [main: "ValidatorsRo"],
      package: package(),
      source_url: "https://github.com/mtarnovan/validators_ro",
      homepage_url: "https://github.com/mtarnovan/validators_ro",
      description: "Validators for Romanian CIF, CNP and IBAN"
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Mihai Târnovan"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/mtarnovan/validators_ro"}
    ]
  end
end
