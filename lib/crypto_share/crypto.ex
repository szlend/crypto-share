defmodule CryptoShare.Crypto do
  def encrypt(data, key) do
    ivec = :crypto.strong_rand_bytes(16)
    enc_data = do_encrypt(ivec, key, data)
    Base.url_encode64(ivec <> enc_data, padding: false)
  end

  def decrypt(base, key) do
    with {:ok, enc} <- Base.url_decode64(base, padding: false),
         {:ok, {enc_data, ivec}} <- extract_ivec(enc),
         {:ok, data} <- do_decrypt(ivec, key, enc_data) do
      {:ok, data}
    else
      _ -> {:error, :decrypt_failed}
    end
  end

  defp do_encrypt(ivec, key, data) do
    :crypto.block_encrypt(:aes_cfb128, ivec, key, data)
  end

  defp do_decrypt(ivec, key, data) do
    case :crypto.block_decrypt(:aes_cfb128, ivec, key, data) do
      :error -> :error
      dec_data -> {:ok, dec_data}
    end
  end

  defp extract_ivec(<< ivec :: binary-size(16), data :: binary >>) do
    {:ok, {data, ivec}}
  end
  defp extract_ivec(_) do
    :error
  end
end
