defmodule CryptoShare.Url do
  def parse(path) do
    {enc_path, extra_path} = CryptoShare.Url.split(path)
    if contained_path?(path, in: Path.join("/", enc_path)) do
      {:ok, {enc_path, extra_path}}
    else
      {:error, :invalid_path}
    end
  end

  def split(enc_path) do
    case String.split(enc_path, "/", parts: 3) do
      ["", enc, path] -> {enc, path}
      ["", enc] -> {enc, "/"}
    end
  end

  def contained_path?(path, in: base_path) do
    path
    |> Path.expand
    |> String.contains?(base_path)
  end
end
