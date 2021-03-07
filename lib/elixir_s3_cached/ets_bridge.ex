defmodule Elixir_S3_Cached.ETSBridge do
  @moduledoc """
  Interface between ETS and the ElixirS3Cached Module.
  """
  @behaviour ElixirS3Cached.Behaviours.Bridge
  alias Elixir_S3_Cached.Bucket

  @doc """
  Gets the `value` from the ETS for a given `key`.

  If the `key` does not exists or is expired will return and `{:error, reason}` tuple.
  If the `key` exists and is not expired, will return a `{:ok, value}` tuple.
  """
  @spec get(any, any) ::
          {:error, :key_not_found | :unknown_error | :wrong_parameters} | {:ok, any}
  def get(%Bucket{} = bucket, key) do
    case lookup(get_key(bucket, key)) do
      nil ->
        {:error, :key_not_found}

      result ->
        check_expiration(result)
    end
  end

  def get(_, _) do
    {:error, :wrong_parameters}
  end

  @doc """
  Sets a `key` in to ETS to `value` that will expire in `ttl` seconds from now
  """
  @spec set(any, any, any, any) :: {:error, :wrong_parameters | term()} | {:ok, term()}
  def set(%Bucket{} = bucket, key, value, ttl) do
    case :ets.insert(ElixirS3Cached, {get_key(bucket, key), value, get_expiration_date(ttl)}) do
      true ->
        {:ok, value}

      _ ->
        {:error, :wrong_parameters}
    end
  end

  def set(_, _, _, _) do
    {:error, :wrong_parameters}
  end

  defp lookup(key) do
    case :ets.lookup(ElixirS3Cached, key) do
      [result | _] -> result
      [] -> nil
    end
  end

  defp check_expiration(result) do
    cond do
      elem(result, 2) > :os.system_time(:seconds) -> {:ok, elem(result, 1)}
      true -> {:error, :key_not_found}
    end
  end

  defp get_expiration_date(ttl) do
    DateTime.utc_now()
    |> DateTime.add(ttl, :second)
    |> DateTime.to_unix()
  end

  defp get_key(%Bucket{prefix: prefix}, key) do
    case prefix do
      "" -> key
      _ -> "#{prefix}/#{key}"
    end
  end
end
