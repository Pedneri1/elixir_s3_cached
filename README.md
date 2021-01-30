# ElixirS3Cached

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `elixir_s3_cached` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:elixir_s3_cached, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/elixir_s3_cached](https://hexdocs.pm/elixir_s3_cached).

## Using in your project

If you want to start the cache manually, you can call `ElixirS3Cached.start_link/3`

```elixir
{:ok, cache} = ElixirS3Cached.start_link("cache_name", "bucket_name", %{})
```

and then, call the function `get/2`

```elixir
value = ElixirS3Cached.get(cache, "key")
```

or `set/3`

```elixir
ElixirS3Cached.set(cache, "key", "value")
```
