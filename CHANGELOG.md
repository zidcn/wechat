# Changelog

## Unreleased
- 移除子模块生成功能: 删除 `gen_sub_module?` 选项以及 `Client.SubModule` 子模块调用方式, 请使用原生调用方式 `WeChat.Material.batch_get_material(Client, ...)`
- 新增 微信支付公钥 支持: `use WeChat.Pay` 可配置 `platform_public_id` / `platform_public_key`, 配置后代替平台证书, 用于验签与敏感信息加解密, 并跳过平台证书的下载与存储

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
