defmodule WeChat.Requester.Work do
  @moduledoc """
  默认的请求客户端(企业微信)

  ```
  A Tesla Client
  adapter: Finch
  BaseUrl: "https://qyapi.weixin.qq.com"
  ```
  """
  @opts Application.compile_env(:wechat, __MODULE__, [])

  @retry_options Keyword.get(@opts, :retry_options,
                   delay: 500,
                   max_retries: 3,
                   max_delay: 2_000,
                   should_retry: &WeChat.Utils.request_should_retry/1
                 )

  defp middleware do
    [
      {Tesla.Middleware.Retry, @retry_options},
      {Tesla.Middleware.JSON, decode_content_types: ["text/plain"]},
      Tesla.Middleware.Logger
    ]
  end

  if Mix.env() == :test do
    defp client do
      Tesla.client(middleware(), Tesla.Mock)
    end
  else
    @adapter_options @opts
                     |> Keyword.get(:adapter_options, pool_timeout: 5_000, receive_timeout: 5_000)
                     |> Keyword.put(:name, WeChat.Finch)
    defp client do
      Tesla.client(
        [{Tesla.Middleware.BaseUrl, "https://qyapi.weixin.qq.com"} | middleware()],
        {Tesla.Adapter.Finch, @adapter_options}
      )
    end
  end

  def get(url, opts \\ []) do
    Tesla.get(client(), url, opts)
  end

  def post(url, body, opts \\ []) do
    Tesla.post(client(), url, body, opts)
  end
end
