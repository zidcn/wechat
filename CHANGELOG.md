# Changelog

## v0.20.1 (2026-08-27)
- 修复动态构建 client 的 bug: `WeChat` / `WeChat.Pay` / `WeChat.Work` 的 `build_client/2` 在 `Module.create` 抛出异常时, 全局编译选项 `ignore_module_conflict` 不会被恢复; 增加 `try/after` 保护, 确保 `Code.compiler_options(ignore_module_conflict: false)` 无论成功还是失败都会被调用
- fix issues #11, thanks @sundevilyang

## v0.20.0 (2026-08-26)
- 新增 微信支付公钥 支持: `use WeChat.Pay` 可配置 `platform_public_id` / `platform_public_key`, 配置后代替平台证书, 用于验签与敏感信息加解密, 并跳过平台证书的下载与存储
  - `client.public_key/0` 始终返回商户公钥(由商户私钥推导); 配置平台公钥后, `encrypt_secret_data/1` 使用平台公钥加密
  - `WeChat.Requester.Pay` 的 `get/3` / `post/4` 新增 `:serial_no` 选项, 用于设置 `wechatpay-serial` 请求头
- 移除子模块生成功能: 删除 `gen_sub_module?` 选项以及 `Client.SubModule` 子模块调用方式, 请使用原生调用方式 `WeChat.Material.batch_get_material(Client, ...)`
- 删除 `WeChat.POI` 模块(微信门店接口)
- 删除 `WeChat.Account.short_url/2`(长链接转短链接接口)
- 删除 `WeChat.MiniProgram.Store.get_card/2`(门店小程序卡券)
- 新增 `WeChat.ServerMessage.ReplyMessage.transfer_ai_msg/3` 转接AI回复
- 更新微信官方文档链接
- 更新依赖(tesla / finch / plug / ex_doc 等)
- fix issues #10, thanks @sundevilyang

## v0.19.0 (2025-10-22)
- remove `client.get/3` & `client.post/4`
- fix tesla builder warning
- update deps

## v0.18.1 (2025-05-17)
- fix SubscribeMessage module warning: clause will never match
- update deps

## v0.18.0 (2025-03-14)
- 解决在第三方平台下的 bugs
- 更新 `WeChat.Component` 模块文档

## v0.17.0 (2024-12-27)
- 不再推荐使用子模块的调用方式
- `gen_sub_module?` 默认值设置为 `false`
- `build_client` 时忽略重定义编译告警

## v0.16.1 (2024-12-24)
- 不再使用即将废弃的语法 `unless`
- 在定义 client 时对于未知属性 进行告警
- 修复一些企业微信场景下的 bug
- 更新依赖

## v0.16.0 (2024-07-31)
- 增加[电子发票接口](https://developers.weixin.qq.com/doc/service/guide/product/weixin_invoice/E_Invoice/Instruction.html): `WeChat.EInvoice`
- 文档优化：所有文档内的链接 改为 完整链接
