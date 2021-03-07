defmodule ElixirS3Cached.Behaviours.Bridge do
  alias Elixir_S3_Cached.Bucket

  @doc """
  Gets the `value` for a given `key`.
  """
  @callback get(%Bucket{}, String.t()) ::
              {:error, :key_not_found | :unknown_error | :wrong_parameters} | {:ok, any}

  @doc """
  Sets a `key` to `value` that will expire in `ttl` seconds from now
  """
  @callback set(%Bucket{}, String.t(), any, integer()) ::
              {:error, :wrong_parameters | term()} | {:ok, term()}
end
