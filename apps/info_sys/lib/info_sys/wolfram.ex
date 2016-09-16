defmodule InfoSys.Wolfram do
  @shortdoc """
  Module to query Wolfram Alpha.
  """

  import SweetXml

  alias InfoSys.Result

  # For testing purposes we mock the backend
  @http Application.get_env(:info_sys, :wolfram)[:http_client] || :httpc

  IO.inspect Application.get_env(:info_sys, :wolfram)

  @doc """
  Using Task and link the process (since 
  this is in a supervision tree) to 
  actually start the process. The Task
  will call fetch/4 function below.
  """
  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  @doc """
  Make an HTTP call to Wolfam Alpha and sends
  the result back to the caller.
  """
  def fetch(query_str, query_ref, owner, _limit) do
    query_str
    |> fetch_xml()
    |> xpath(~x"/queryresult/pod[contains(@title, 'Result') or contains(@title, 'Definitions')]/subpod/plaintext/text()")
    |> send_results(query_ref, owner)
  end

  @doc """
  Send results back to the caller.
  """
  def send_results(nil, query_ref, owner) do
    send(owner, {:results, query_ref, []})
  end
  def send_results(answer, query_ref, owner) do
    results = [%Result{
      backend: "wolfram",
      score: 95,
      text: to_string(answer)
    }]

    send(owner, {:results, query_ref, results})
  end

  @doc """
  Call Wolfram Alpha.
  """
  def fetch_xml(query_str) do
    {:ok, {_, _, body}} = 
      @http.request(String.to_char_list("http://api.wolframalpha.com/v2/query" <> "?appid=#{app_id()}" <> "&input=#{URI.encode(query_str)}&format=plaintext"))
      body
  end

  @doc """
  Get Wolfram App ID.
  """
  def app_id do
    Application.get_env(:info_sys, :wolfram)[:app_id]
  end
end
