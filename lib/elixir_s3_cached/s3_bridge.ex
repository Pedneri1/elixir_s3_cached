defmodule Elixir_S3_Cached.S3Bridge do
  @moduledoc """
  Interface between S3 and the ElixirS3Cached Module.
  """
  @behaviour ElixirS3Cached.Behaviours.Bridge
  alias ExAws.S3
  alias Elixir_S3_Cached.Bucket

  @doc """
  Sets an object (`value`) into S3 with the `key` name
  """
  @spec set(any, any, any, any) :: {:error, :wrong_parameters | term()} | {:ok, term()}
  def set(%Bucket{name: bucket_name} = bucket, key, value, _ttl) do
    case S3.put_object(bucket_name, get_key(bucket, key), value)
         |> ExAws.request() do
      {:error, reason} ->
        {:error, reason}

      {:ok, _data} ->
        {:ok, key}
    end
  end

  def set(_, _, _, _) do
    {:error, :wrong_parameters}
  end

  @doc """
  Gets the `value` from the S3 for a given `key`.

  If the `key` does not exists or is expired will return and `{:error, reason}` tuple.
  If the `key` exists and is not expired, will return a `{:ok, value}` tuple.
  """
  @spec get(any, any) ::
          {:error, :key_not_found | :unknown_error | :wrong_parameters} | {:ok, any}
  def get(%Bucket{name: bucket_name} = bucket, key) do
    case S3.get_object(bucket_name, get_key(bucket, key)) |> ExAws.request() do
      {:error, {_error, code, _data}} ->
        cond do
          code == 404 ->
            {:error, :key_not_found}

          true ->
            {:error, :unknown_error}
        end

      {:ok, %{body: body}} ->
        {:ok, body}
    end
  end

  def get(_, _) do
    {:error, :wrong_parameters}
  end

  defp get_key(%Bucket{prefix: prefix}, key) do
    case prefix do
      "" -> key
      _ -> "#{prefix}/#{key}"
    end
  end
end
