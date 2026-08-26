defmodule WeChat.Pay.PlatformPublicKeyTest do
  @moduledoc """
  微信支付公钥(platform_public_id/platform_public_key)测试
  """
  use ExUnit.Case

  alias WeChat.Pay
  alias WeChat.Pay.{Certificates, Crypto}

  @key_file "test/support/cert/apiclient_key.pem"
  @cert_file "test/support/cert/apiclient_cert.pem"
  @platform_public_key_file "test/support/cert/platform_public_key.pem"
  @platform_private_key_file "test/support/cert/platform_private_key.pem"
  @public_id "PUB_KEY_ID_TEST_00000000000000000000000000000000"

  defp base_options do
    [
      mch_id: "1900000109",
      api_secret_key: "api_secret_v3_key",
      api_secret_v2_key: "api_secret_v2_key",
      client_serial_no: "client_serial_no",
      client_key: {:file, @key_file}
    ]
  end

  defp platform_public_key_pem, do: File.read!(@platform_public_key_file)

  defp platform_private_key do
    @platform_private_key_file |> File.read!() |> X509.PrivateKey.from_pem!()
  end

  defp merchant_private_key do
    @key_file |> File.read!() |> X509.PrivateKey.from_pem!()
  end

  defp decrypt(cipher, private_key) do
    Crypto.decrypt_secret_data(cipher, private_key)
  rescue
    _ -> :decrypt_failed
  end

  defp build_client(module, options) do
    {:ok, client} = Pay.build_client(module, Keyword.merge(base_options(), options))
    client
  end

  test "legacy client: no platform public key, public_key derived from private key" do
    client = build_client(WeChat.Test.PubKeyLegacy, [])

    assert client.platform_public_id() == nil
    assert client.platform_public_key() == nil

    assert client.public_key() == X509.PublicKey.derive(merchant_private_key())
  end

  test "configured platform public key: public_key stays merchant key" do
    client =
      build_client(WeChat.Test.PubKeyClient,
        platform_public_id: @public_id,
        platform_public_key: {:binary, platform_public_key_pem()}
      )

    assert client.platform_public_id() == @public_id
    assert is_tuple(client.platform_public_key())

    # public_key 始终是商户公钥, 与是否配置平台公钥无关
    assert client.public_key() == X509.PublicKey.derive(merchant_private_key())
    refute client.public_key() == client.platform_public_key()

    # platform_public_key 是独立的平台公钥
    assert client.platform_public_key() ==
             @platform_public_key_file |> File.read!() |> X509.PublicKey.from_pem!()
  end

  test "encrypt_secret_data uses the platform public key" do
    client =
      build_client(WeChat.Test.PubKeyEncrypt,
        platform_public_id: @public_id,
        platform_public_key: {:binary, platform_public_key_pem()}
      )

    plain = "sensitive-name-张三"
    cipher = client.encrypt_secret_data(plain)

    # 平台公钥加密 => 只有平台私钥能解开
    assert decrypt(cipher, platform_private_key()) == plain
    # 商户私钥解不开 => 确认没有误用商户公钥加密
    assert decrypt(cipher, client.private_key()) == :decrypt_failed
  end

  test "Certificates.put_platform_public_key stores the public key for 验签" do
    client =
      build_client(WeChat.Test.PubKeyCerts,
        platform_public_id: @public_id,
        platform_public_key: {:binary, platform_public_key_pem()}
      )

    :ok = Certificates.put_platform_public_key(client)
    assert Certificates.get_cert(client, @public_id) == client.platform_public_key()
  end

  test "Certificates.put_certs still accepts a certificate entry" do
    client = build_client(WeChat.Test.PubKeyPutCert, [])

    certificate = File.read!(@cert_file)

    :ok =
      Certificates.put_certs(
        [%{"serial_no" => "SERIAL_ABC", "certificate" => certificate}],
        client
      )

    assert is_tuple(Certificates.get_cert(client, "SERIAL_ABC"))
  end

  test "invalid config raises" do
    assert_raise ArgumentError, ~r/platform_public_id/, fn ->
      Pay.build_client(
        WeChat.Test.PubKeyErr1,
        [
          platform_public_key: {:binary, platform_public_key_pem()}
        ] ++ base_options()
      )
    end

    assert_raise ArgumentError, ~r/platform_public_key/, fn ->
      Pay.build_client(
        WeChat.Test.PubKeyErr2,
        [
          platform_public_id: @public_id
        ] ++ base_options()
      )
    end

    assert_raise ArgumentError, ~r/platform_public_id/, fn ->
      Pay.build_client(
        WeChat.Test.PubKeyErr3,
        [
          platform_public_id: :not_binary,
          platform_public_key: {:binary, platform_public_key_pem()}
        ] ++ base_options()
      )
    end
  end
end
