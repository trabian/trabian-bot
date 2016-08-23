defmodule GitHub do
  use HTTPoison.Base

  def process_url(url) do
    endpoint = Application.get_env(:git_hub, :endpoint)
    if String.starts_with?(url, endpoint) do
      url
    else
      endpoint <> url
    end
  end

  defp process_request_headers(headers) do
    headers
    |> Enum.into(Application.get_env(:git_hub, :headers, []))
    |> authorization_headers
  end

  defp process_response_body(body) do
    body
    |> Poison.decode!
  end

  defp authorization_headers(headers) do
    case Application.get_env(:git_hub, :access_token) do
      nil -> headers
      token -> headers ++ [{"Authorization", "token #{token}"}]
    end
  end
end
