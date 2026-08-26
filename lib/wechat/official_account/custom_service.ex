defmodule WeChat.CustomService do
  @moduledoc """
  客服消息/客服管理

  [官方文档](https://developers.weixin.qq.com/doc/service/guide/product/kf/intro.html){:target="_blank"}
  """
  import Jason.Helpers
  alias Tesla.Multipart

  @doc_link "https://developers.weixin.qq.com/doc/service/api/customer/servicermanage"

  @typedoc """
  完整客服账号，格式为：账号前缀@公众号微信号
  """
  @type kf_account :: String.t()
  @typedoc "客服昵称"
  @type nickname :: String.t()
  @typedoc """
  客服账号登录密码

  格式为密码明文的32位加密MD5值。该密码仅用于在公众平台官网的多客服功能中使用，若不使用多客服功能，则不必设置密码。
  """
  @type password :: String.t()

  @doc """
  添加客服帐号 -
  [官方文档](#{@doc_link}/api_addkfaccount.html){:target="_blank"}

  每个公众号最多添加100个客服账号。
  """
  @spec add_kf_account(WeChat.client(), kf_account, nickname, password) :: WeChat.response()
  def add_kf_account(client, kf_account, nickname, password) do
    client.post(
      "/cgi-bin/customservice/kfaccount/add",
      json_map(kf_account: kf_account, nickname: nickname, password: password),
      query: [access_token: client.get_access_token()]
    )
  end

  @doc """
  修改客服帐号 -
  [官方文档](#{@doc_link}/api_updatekfaccount.html){:target="_blank"}
  """
  @spec update_kf_account(WeChat.client(), kf_account, nickname, password) :: WeChat.response()
  def update_kf_account(client, kf_account, nickname, password) do
    client.post(
      "/cgi-bin/customservice/kfaccount/update",
      json_map(kf_account: kf_account, nickname: nickname, password: password),
      query: [access_token: client.get_access_token()]
    )
  end

  @doc """
  删除客服帐号 -
  [官方文档](#{@doc_link}/api_delkfaccount.html){:target="_blank"}
  """
  @spec del_kf_account(WeChat.client(), kf_account, nickname, password) :: WeChat.response()
  def del_kf_account(client, kf_account, nickname, password) do
    client.post(
      "/cgi-bin/customservice/kfaccount/del",
      json_map(kf_account: kf_account, nickname: nickname, password: password),
      query: [access_token: client.get_access_token()]
    )
  end

  @doc """
  设置客服头像 -
  [官方文档](#{@doc_link}/api_uploadkfheadimg.html){:target="_blank"}

  头像图片文件必须是jpg格式，推荐使用640*640大小的图片以达到最佳效果。
  """
  @spec upload_head_img(WeChat.client(), kf_account, path :: Path.t()) :: WeChat.response()
  def upload_head_img(client, kf_account, path) do
    multipart =
      Multipart.new()
      |> Multipart.add_file(path, name: "media", detect_content_type: true)

    client.post("/cgi-bin/customservice/kfaccount/uploadheadimg", multipart,
      query: [
        kf_account: kf_account,
        access_token: client.get_access_token()
      ]
    )
  end

  @doc """
  设置客服头像(binary) -
  [官方文档](#{@doc_link}/api_uploadkfheadimg.html){:target="_blank"}

  头像图片文件必须是jpg格式，推荐使用640*640大小的图片以达到最佳效果。
  """
  @spec upload_head_img(WeChat.client(), kf_account, filename :: String.t(), data :: binary) ::
          WeChat.response()
  def upload_head_img(client, kf_account, filename, data) do
    multipart =
      Multipart.new()
      |> Multipart.add_file_content(data, filename, name: "media", detect_content_type: true)

    client.post("/cgi-bin/customservice/kfaccount/uploadheadimg", multipart,
      query: [
        kf_account: kf_account,
        access_token: client.get_access_token()
      ]
    )
  end

  @doc """
  获取所有客服账号 -
  [官方文档](#{@doc_link}/api_getkflist.html){:target="_blank"}

  获取公众号中所设置的客服基本信息，包括客服工号、客服昵称、客服登录账号。
  """
  @spec get_kf_list(WeChat.client()) :: WeChat.response()
  def get_kf_list(client) do
    client.get("/cgi-bin/customservice/getkflist",
      query: [access_token: client.get_access_token()]
    )
  end
end
