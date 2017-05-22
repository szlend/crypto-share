defmodule CryptoShare.Router do
  import Plug.Conn
  require Logger

  def init([]), do: false

  def call(conn, _opts) do
    Logger.info "Requested #{conn.request_path}"
    with {:ok, {enc_path, right_path}} <- CryptoShare.Url.parse(conn.request_path),
         {:ok, left_path} <- CryptoShare.Crypto.decrypt(enc_path, encryption_key()),
         path <- Path.join(left_path, right_path) do

      Logger.info "Returning #{path}"
      conn
      |> put_resp_content_type("text/plain")
      |> put_resp_header("X-Accel-Redirect", path)
      |> send_resp(200, path)
    else
      {:error, :decrypt_failed} ->
        Logger.error "Failed to decrypt url #{conn.request_path}"
        send_resp(conn, 401, "")
      {:error, :invalid_url} ->
        Logger.error "Invalid url #{conn.request_path}"
        send_resp(conn, 401, "")
      {:error, reason} ->
        Logger.error "Failed with reason #{inspect reason}"
        send_resp(conn, 401, "")
    end
  end

  defp encryption_key do
    case Application.get_env(:crypto_share, :encryption_key) do
      << key :: bytes-size(16) >> -> key
      _ -> raise "Not a valid 128-bit encryption key"
    end
  end
end
