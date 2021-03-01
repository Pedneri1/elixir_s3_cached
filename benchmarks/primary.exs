alias ElixirS3Cached

{:ok, cache} = ElixirS3Cached.start_link("benchmarks", "elixir-s3-cache", %{})
#Makes sure that the bucket is previously create, so the get function wont return 404
ElixirS3Cached.set(cache, "set_key", "set_value")

benchmarks = %{
  "set" => fn -> ElixirS3Cached.set(cache, "set_key", "set_value") end,
  "get" => fn -> ElixirS3Cached.get(cache, "set_key") end
}

Benchee.run(
  benchmarks, [
    formatters: [
      {
        Benchee.Formatters.Console,
        [
          comparison: false,
          extended_statistics: true
        ]
      },
      {
        Benchee.Formatters.HTML,
        [
          auto_open: false
        ]
      }
    ],
    print: [
      fast_warning: false
    ]
  ]
)
