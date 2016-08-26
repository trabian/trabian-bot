defmodule TrabianBot.Mixfile do
  use Mix.Project

  def project do
    [apps_path: "apps",
     version: append_revision("0.0.1"),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: [test: "test --no-start"],
     #applications: [:edeliver],
     deps: deps]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    [
      {:distillery, "~> 0.9"},
      {:edeliver, "~> 1.4.0"},
      {:credo, "~> 0.4", only: [:dev, :test]}
    ]
  end

  defp append_revision(version) do
    "#{version}+#{revision}"
  end

  defp revision() do
    System.cmd("git", ["rev-parse", "--short", "HEAD"])
    |> elem(0)
    |> String.rstrip
  end
end
