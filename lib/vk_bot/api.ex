defmodule VkBot.Api do

  @token Application.compile_env!(:vk_bot, :token)
  @version "5.131"

  @auth_fields %{"access_token" => @token, "v" => @version}
  @api_server URI.new!("https://api.vk.com/method/")

  def send_request(url) do
    url
    |> HTTPoison.get!([], timeout: 30_000, recv_timeout: 30_000)
    |> Map.get(:body)
    |> Jason.decode!()
  end

  defp parse_response(response) do
    case response do
      %{"response" => resp} -> resp
      %{"error" => err} -> throw(err)
    end
  end

  def exec_method(method, params \\ %{}) when is_binary(method) do
    query =
      Map.merge(params, @auth_fields)
      |> URI.encode_query()

    URI.merge(@api_server, method)
    |> URI.append_query(query)
    |> URI.to_string()
    |> send_request()
    |> parse_response()
  end
end
