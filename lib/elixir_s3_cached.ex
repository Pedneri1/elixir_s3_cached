defmodule ElixirS3Cached do
  @moduledoc """
  Uses S3 as a key/value cache with support to expiration
  """
  alias Elixir_S3_Cached.S3Bridge
  alias Elixir_S3_Cached.Bucket
  alias Elixir_S3_Cached.ETSBridge

  use GenServer

  @default_timeout 5000

  @typedoc """
  The name of the bucket in AWS S3. Note: the bucket must be created before using this lib.
  """
  @type bucket_name :: binary | atom

  @typedoc """
  The S3 Prefix of the object. Accepts atom or binary but it's always converted to binary
  """
  @type prefix :: binary | atom

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

  def start_link(bucket_name, %{} = config, prefix \\ "", opts \\ []) do
    config =
      config
      |> Map.put_new(:bucket, %Bucket{
        name: bucket_name,
        prefix: prefix
      })

    GenServer.start_link(__MODULE__, config, opts)
  end

  def get(pid, key, opts \\ []),
    do: GenServer.call(pid, {:get, key}, opts[:timeout] || @default_timeout)

  def set(pid, key, value, ttl \\ 3600), do: GenServer.call(pid, {:set, key, value, ttl})

  def clear(pid), do: GenServer.call(pid, :clear)

  # Server(callbacks)
  @impl true
  def init(init_args) do
    generate_table()
    {:ok, init_args}
  end

  @impl true
  def handle_call({:get, key}, _from, %{bucket: bucket} = config) do
    case ETSBridge.get(bucket, key) do
      {:error, :key_not_found} ->
        {:reply, S3Bridge.get(bucket, key), config}

      response ->
        {:reply, response, config}
    end
  end

  @impl true
  def handle_call({:set, key, value, ttl}, _from, %{bucket: bucket} = config) do
    case S3Bridge.set(bucket, key, value, ttl) do
      {:ok, _} = response ->
        ETSBridge.set(bucket, key, value, ttl)
        {:reply, response, config}

      {:error, _} = response ->
        {:reply, response, config}
    end
  end

  @impl true
  def handle_call(:clear, _from, %{bucket: _bucket} = config) do
    :ets.delete(ElixirS3Cached)
    generate_table()
    {:reply, :ok, config}
  end

  defp generate_table do
    :ets.new(ElixirS3Cached, [:set, :protected, :named_table])
  end
end
