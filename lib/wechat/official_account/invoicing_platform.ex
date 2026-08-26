defmodule WeChat.InvoicingPlatform do
  @moduledoc """
  开票平台

  [官方文档](https://developers.weixin.qq.com/doc/service/guide/product/weixin_invoice/E_Invoice/Instruction.html){:target="_blank"}
  [开票平台接口列表](https://developers.weixin.qq.com/doc/service/guide/product/weixin_invoice/E_Invoice/Invoicing_Platform_API_List.html){:target="_blank"}
  """

  @doc_link "https://developers.weixin.qq.com/doc/service/api/invoice"

  @doc """
  获取自身的开票平台识别码 -
  [官方文档](#{@doc_link}/FiscalReceipt/api_setinvoiceurl.html){:target="_blank"}
  """
  @spec get_url(WeChat.client()) :: WeChat.response()
  def get_url(client) do
    client.post("/card/invoice/seturl", %{}, query: [access_token: client.get_access_token()])
  end

  @doc """
  创建发票卡券模板 -
  [官方文档](#{@doc_link}/platform/api_invoiceplatformcreatecard.html){:target="_blank"}
  """
  @spec create_card(WeChat.client(), body :: map) :: WeChat.response()
  def create_card(client, body) do
    client.post("/card/invoice/platform/createcard", body,
      query: [access_token: client.get_access_token()]
    )
  end

  @doc """
  上传PDF -
  [官方文档](#{@doc_link}/FiscalReceipt/api_invoiceplatformsetpdf.html){:target="_blank"}
  """
  @spec set_pdf(WeChat.client(), body :: map) :: WeChat.response()
  def set_pdf(client, body) do
    client.post("/card/invoice/platform/setpdf", body,
      query: [access_token: client.get_access_token()]
    )
  end

  @doc """
  查询已上传的PDF文件 -
  [官方文档](#{@doc_link}/FiscalReceipt/api_invoiceplatformgetpdf.html){:target="_blank"}
  """
  @spec get_pdf(WeChat.client(), body :: map) :: WeChat.response()
  def get_pdf(client, body) do
    client.post("/card/invoice/platform/getpdf", body,
      query: [access_token: client.get_access_token()]
    )
  end

  @doc """
  将电子发票卡券插入用户卡包 -
  [官方文档](#{@doc_link}/platform/api_insertinvoice.html){:target="_blank"}
  """
  @spec insert(WeChat.client(), body :: map) :: WeChat.response()
  def insert(client, body) do
    client.post("/card/invoice/insert", body, query: [access_token: client.get_access_token()])
  end

  @doc """
  更新发票卡券状态 -
  [官方文档](#{@doc_link}/FiscalReceipt/api_invoicekpupdatainvoicestatus.html){:target="_blank"}
  """
  @spec update_status(WeChat.client(), body :: map) :: WeChat.response()
  def update_status(client, body) do
    client.post("/card/invoice/platform/updatestatus", body,
      query: [access_token: client.get_access_token()]
    )
  end

  defdelegate decrypt_code(client, encrypt_code), to: WeChat.Card
end
