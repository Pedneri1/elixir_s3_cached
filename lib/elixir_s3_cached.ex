defmodule ElixirS3Cached do
  @moduledoc """
  Uses S3 as a key/value cache with support to expiration
  """
  alias Elixir_S3_Cached.S3Bridge
  alias Elixir_S3_Cached.Bucket

  use GenServer

  @default_timeout 5000

  @typedoc """
  The name of the bucket in AWS S3. Note: the bucket must be created before using this lib.
  """
  @type bucket_name :: binary | atom

  @typedoc """
  The name of the cache. Will be used for namespacing the caches inside the bucket. Accepts atom or binary
  but it's always converted to binary
  """
  @type cache_name :: binary | atom

  @typedoc """
  The key which the value will be set under. Accepts atom or binary but will always be converted to binary.
  """
  @type key :: binary | atom

  @typedoc """
  The value you want to save in the cache. Can be any value, map, struct or other Elixir supported type. However
  the values are always converted to strings because we use Jason lib to encode and decode the values that go in/out the cache
  """
  @type value :: term

  @typedoc """
  An array with the data about the timeout given to the `GenServer.call` function.
  """
  @type options :: [timeout: integer]

  def start_link(cache_name, bucket_name, %{} = config, opts \\ []) do
    config =
      config
      |> Map.put_new(:bucket, %Bucket{name: bucket_name, cache: cache_name})

    GenServer.start_link(__MODULE__, config, opts)
  end

  def get(pid, key, opts \\ []),
    do: GenServer.call(pid, {:get, key}, opts[:timeout] || @default_timeout)

  def set(pid, key, value, ttl \\ 3600), do: GenServer.call(pid, {:set, key, value, ttl})

  # Server(callbacks)
  @impl true
  def init(init_args) do
    {:ok, init_args}
  end

  @impl true
  def handle_call({:get, key}, _from, config) do
    {:reply, S3Bridge.get(config[:bucket], key), config}
  end

  @impl true
  def handle_call({:set, key, value, ttl}, _from, config) do
    IO.inspect(config)
    {:reply, S3Bridge.set(config[:bucket], key, value, ttl), config}
  end
end
