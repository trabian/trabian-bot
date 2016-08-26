defmodule GitHub do
  @moduledoc """
  This module provides an HTTP client for GitHub by wrapping
  [HTTPoison.Base](https://github.com/edgurgel/httpoison#wrapping-httpoisonbase).

  The following items are set via config:

    * `:endpoint` **required** -- The API endpoint URL. For example:
      "https://api.github.com"
      
    * `:token` **required** -- The API user's token.

    * `:headers` *optional* -- Any additional headers for requests.
      For example, as of writing the GitHub "Reactions" API requires
      an "Accept" header of
      "application/vnd.github.squirrel-girl-preview", so the config
      is:

  ```
  config :git_hub, headers: [
    {"Accept", "application/vnd.github.squirrel-girl-preview"} 
  ]
  ```
  """
  
  use HTTPoison.Base

  @doc """
  Get the `url` and extract the JSON body from the response.
  """
  def get_body(url) do
    url
    |> get()
    |> extract_body()
  end

  @doc """
  HTTPPoison callback. This will prepend the `:endpoint` to the url
  unless it's already present.
  """
  def process_url(url) do
    endpoint = Config.get(:git_hub, :endpoint)
    if String.starts_with?(url, endpoint) do
      url
    else
      endpoint <> url
    end
  end

  defp process_request_headers(headers) do
    headers
    |> Enum.into(Config.get(:git_hub, :headers, []))
    |> authorization_headers
  end

  defp process_response_body(body) do
    body
    |> Poison.decode!
  end

  defp authorization_headers(headers) do
    case Config.get(:git_hub, :access_token) do
      nil -> headers
      token -> headers ++ [{"Authorization", "token #{token}"}]
    end
  end

  defp extract_body({:ok, %{body: body}}) do
    body
  end
  
end
