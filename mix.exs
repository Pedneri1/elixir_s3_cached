defmodule ElixirS3Cached.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :elixir_s3_cached,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      description: "AWS S3 based caching for Elixir",
      deps: deps(),
      package: [
        licenses: ["MIT"],
        mainteners: ["Pedro Neri<pedneri1@gmail.com>"],
        links: %{"GitHub" => "https://github.com/Pedneri1/elixir_s3_cached"}
      ],
      name: "Elixir S3 Cached",
      aliases: [
        bench: "run benchmarks/primary.exs"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
      {:jason, "~> 1.2"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:benchee, "~> 1.0", optional: true, only: :dev},
      {:benchee_html, "~> 1.0", optional: true, only: :dev}
    ]
  end
end
