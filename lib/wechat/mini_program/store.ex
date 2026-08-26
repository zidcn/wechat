defmodule WeChat.MiniProgram.Store do
  @moduledoc """
  小程序 - 门店接口

  [官方文档](https://developers.weixin.qq.com/doc/service/guide/product/WeChat_Store.html){:target="_blank"}
  """
  import Jason.Helpers

  @doc_link "https://developers.weixin.qq.com/doc/service/api/stores/miniapp"

  @type poi_id :: String.t()
  @typedoc "对应 拉取省市区信息接口 中的id字段"
  @type district_id :: String.t()
  @typep body :: map

  @doc """
  申请门店 -
  [官方文档](#{@doc_link}/api_applywxastore.html){:target="_blank"}

  创建门店小程序提交后需要公众号管理员确认通过后才可进行审核。如果主管理员24小时超时未确认，才能再次提交。
  """
  @spec apply(WeChat.client(), body) :: WeChat.response()
  def apply(client, body) do
    client.post("/wxa/apply_merchant", body, query: [access_token: client.get_access_token()])
  end

  @doc """
  查询门店小程序审核结果 -
  [官方文档](#{@doc_link}/api_getwxastoreauditinfo.html){:target="_blank"}

  创建门店小程序提交后需要公众号管理员确认通过后才可进行审核。如果主管理员24小时超时未确认，才能再次提交。
  """
  @spec query_audit_info(WeChat.client()) :: WeChat.response()
  def query_audit_info(client) do
    client.get("/wxa/get_merchant_audit_info", query: [access_token: client.get_access_token()])
  end

  @doc """
  修改门店小程序信息 -
  [官方文档](#{@doc_link}/api_modifywxastore.html){:target="_blank"}
  """
  @spec modify(WeChat.client(), body) :: WeChat.response()
  def modify(client, body) do
    client.post("/wxa/modify_merchant", body, query: [access_token: client.get_access_token()])
  end

  @doc """
  获取省市区信息 -
  [官方文档](#{@doc_link}/api_getdistrictlist.html){:target="_blank"}
  """
  @spec get_district(WeChat.client()) :: WeChat.response()
  def get_district(client) do
    client.get("/wxa/get_district", query: [access_token: client.get_access_token()])
  end

  @doc """
  搜索门店地图信息 -
  [官方文档](#{@doc_link}/api_poilistsearch.html){:target="_blank"}
  """
  @spec map_search(WeChat.client(), district_id, keyword :: String.t()) :: WeChat.response()
  def map_search(client, district_id, keyword) do
    client.post("/wxa/search_map_poi", json_map(district_id: district_id, keyword: keyword),
      query: [access_token: client.get_access_token()]
    )
  end

  @doc """
  在地图中创建门店 -
  [官方文档](#{@doc_link}/api_createnewpoid.html){:target="_blank"}
  """
  @spec create_map_poi(WeChat.client(), body) :: WeChat.response()
  def create_map_poi(client, body) do
    client.post("/wxa/create_map_poi", body, query: [access_token: client.get_access_token()])
  end

  @doc """
  新增门店 -
  [官方文档](#{@doc_link}/api_addentityshop.html){:target="_blank"}
  """
  @spec add(WeChat.client(), body) :: WeChat.response()
  def add(client, body) do
    client.post("/wxa/add_store", body, query: [access_token: client.get_access_token()])
  end

  @doc """
  更新门店信息 -
  [官方文档](#{@doc_link}/api_newupdatepoi.html){:target="_blank"}
  """
  @spec update(WeChat.client(), body) :: WeChat.response()
  def update(client, body) do
    client.post("/wxa/update_store", body, query: [access_token: client.get_access_token()])
  end

  @doc """
  获取门店详情 -
  [官方文档](#{@doc_link}/api_newgetpoi.html){:target="_blank"}
  """
  @spec get(WeChat.client(), poi_id) :: WeChat.response()
  def get(client, poi_id) do
    client.post("/wxa/get_store_info", json_map(poi_id: poi_id),
      query: [access_token: client.get_access_token()]
    )
  end

  @doc """
  获取门店列表 -
  [官方文档](#{@doc_link}/api_newgetpoilist.html){:target="_blank"}
  """
  @spec list(WeChat.client(), offset :: integer, limit :: integer) :: WeChat.response()
  def list(client, offset \\ 0, limit \\ 20) when limit <= 50 do
    client.post("/wxa/get_store_list", json_map(offset: offset, limit: limit),
      query: [access_token: client.get_access_token()]
    )
  end

  @doc """
  删除门店 -
  [官方文档](#{@doc_link}/api_newdelpoi.html){:target="_blank"}
  """
  @spec delete(WeChat.client(), poi_id) :: WeChat.response()
  def delete(client, poi_id) do
    client.post("/wxa/del_store", json_map(poi_id: poi_id),
      query: [access_token: client.get_access_token()]
    )
  end

  @doc """
  拉取门店小程序类目 -
  [官方文档](#{@doc_link}/api_getwxastorecatelist.html){:target="_blank"}
  """
  @spec list_category(WeChat.client()) :: WeChat.response()
  def list_category(client) do
    client.get("/wxa/get_merchant_category", query: [access_token: client.get_access_token()])
  end
end
