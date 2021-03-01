defmodule Elixir_S3_Cached.S3Bridge do
  @moduledoc """
  Interface between S3 and the ElixirS3Cached Module.
  """

  alias ExAws.S3
  alias Elixir_S3_Cached.Bucket

  @doc """
  Sets a `key` in to S3 to `value` that will expire in `ttl` seconds from now
  """
  @spec set(any, any, any, any) :: {:error, :wrong_parameters | term()} | {:ok, term()}
  def set(%Bucket{name: bucket_name} = bucket, key, value, ttl) do
    case S3.put_object(bucket_name, get_key(bucket, key), Jason.encode!(value), [
           {:expires, get_expiration_date(ttl)}
         ])
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
    case S3.get_object(bucket_name, get_key(bucket, key))
         |> ExAws.request() do
      {:error, {_error, code, _data}} ->
        cond do
          code == 404 ->
            {:error, :key_not_found}

          true ->
            {:error, :unknown_error}
        end

      {:ok, %{body: body} = response} ->
        with expiration <- get_expiration(response),
             {:ok, :alive} <- check_expiration(expiration) do
          {:ok, Jason.decode!(body)}
        else
          {:error, :dead} ->
            {:error, :key_not_found}
        end
    end
  end

  def get(_, _) do
    {:error, :wrong_parameters}
  end

  defp get_expiration_date(ttl) do
    DateTime.utc_now()
    |> DateTime.add(ttl, :second)
    |> DateTime.to_unix()
  end

  defp get_key(%Bucket{cache: cache_name}, key) do
    "#{cache_name}/#{key}"
  end

  defp get_expiration(%{headers: headers} = _object) do
    Enum.find(headers, fn {metadata, _} -> metadata == "Expires" end)
  end

  defp check_expiration({_, data} = _expiration) do
    with {expiration, _} <- Integer.parse(data),
         {:ok, expiration_time} <- DateTime.from_unix(expiration),
         time_now <- DateTime.utc_now() do
      case DateTime.compare(time_now, expiration_time) do
        :gt ->
          {:error, :dead}

        _ ->
          {:ok, :alive}
      end
    end
  end
end
