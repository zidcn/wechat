defmodule WeChat.Builder.Pay do
  @moduledoc false
  alias WeChat.Builder.Utils
  @compile {:no_warn_undefined, X509.PrivateKey}
  @compile {:no_warn_undefined, X509.PublicKey}
  @known_option_keys [
    :mch_id,
    :api_secret_v2_key,
    :api_secret_key,
    :client_serial_no,
    :client_key,
    :platform_public_id,
    :platform_public_key,
    :requester,
    :storage
  ]

  defmacro __using__(options \\ []) do
    if !Code.ensure_loaded?(X509) do
      raise ArgumentError, "Please add :x509 to deps before use WeChatPay!!!"
    end

    client = __CALLER__.module
    options = check_options!(options, client, __CALLER__)
    requester = Map.get(options, :requester, WeChat.Requester.Pay)
    storage = Map.get(options, :storage, WeChat.Storage.PayFile)

    encrypt_secret_data_fun =
      if options.platform_public_key do
        quote do
          @doc "加密敏感信息"
          def encrypt_secret_data(data) do
            WeChat.Pay.Crypto.encrypt_secret_data(data, unquote(options.platform_public_key))
          end
        end
      else
        quote do
          @doc "加密敏感信息"
          def encrypt_secret_data(data) do
            WeChat.Pay.Crypto.encrypt_secret_data(data, unquote(options.public_key))
          end
        end
      end

    quote do
      use Supervisor

      @spec start_link(WeChat.Pay.start_options()) :: Supervisor.on_start()
      def start_link(opts) do
        Supervisor.start_link(__MODULE__, Map.new(opts), name: :"#{__MODULE__}.Supervisor")
      end

      @impl true
      def init(opts) do
        refresher = Map.get(opts, :refresher, WeChat.Refresher.Pay)

        children = [
          {refresher, Map.put(opts, :client, __MODULE__)}
          | WeChat.Pay.get_requester_specs(__MODULE__, opts)
        ]

        Supervisor.init(children, strategy: :one_for_one)
      end

      @spec get(url :: binary, opts :: keyword) :: WeChat.response()
      def get(url, opts \\ []), do: unquote(requester).get(__MODULE__, url, opts)
      @spec post(url :: binary, body :: any, opts :: keyword) :: WeChat.response()
      def post(url, body, opts \\ []), do: unquote(requester).post(__MODULE__, url, body, opts)
      @spec v2_post(url :: binary, body :: any, opts :: keyword) :: WeChat.response()
      def v2_post(url, body, opts \\ []),
        do: unquote(requester).v2_post(__MODULE__, url, body, opts)

      @spec mch_id() :: WeChat.Pay.mch_id()
      def mch_id, do: unquote(options.mch_id)
      @spec client_serial_no() :: WeChat.Pay.client_serial_no()
      def client_serial_no, do: unquote(options.client_serial_no)
      @spec storage() :: WeChat.Storage.Adapter.t()
      def storage, do: unquote(storage)
      @doc false
      unquote(options.api_secret_key)
      @doc false
      unquote(options.api_secret_v2_key)
      @doc false
      def public_key, do: unquote(options.public_key)
      @doc false
      def private_key, do: unquote(options.private_key)
      @doc "微信支付公钥ID"
      def platform_public_id, do: unquote(options.platform_public_id)
      @doc "微信支付公钥"
      def platform_public_key, do: unquote(options.platform_public_key)

      unquote(encrypt_secret_data_fun)

      @doc "解密敏感信息"
      def decrypt_secret_data(cipher_text) do
        WeChat.Pay.Crypto.decrypt_secret_data(cipher_text, unquote(options.private_key))
      end
    end
  end

  defp check_options!(options, client, caller) do
    options = options |> Macro.prewalk(&Macro.expand(&1, caller)) |> Map.new()
    Utils.warn_unknown_option(options, @known_option_keys, client)

    if !(Map.get(options, :mch_id) |> is_binary()) do
      raise ArgumentError, "Please set mch_id option for #{inspect(client)}"
    end

    if !(Map.get(options, :client_serial_no) |> is_binary()) do
      raise ArgumentError, "Please set client_serial_no option for #{inspect(client)}"
    end

    api_secret_key = Map.get(options, :api_secret_key) |> check_api_key(:api_secret_key, client)

    api_secret_v2_key =
      Map.get(options, :api_secret_v2_key) |> check_api_key(:api_secret_v2_key, client)

    private_key =
      case Map.get(options, :client_key) |> check_pem_file() do
        {:bad_arg, pem_file} ->
          raise ArgumentError,
                "Bad client_key: #{inspect(pem_file)} option for #{inspect(client)}"

        :unset ->
          raise ArgumentError, "Please set client_key option for #{inspect(client)}"

        pem_file ->
          pem_file |> read_pem!() |> X509.PrivateKey.from_pem!()
      end

    platform_public_id = Map.get(options, :platform_public_id)

    platform_public_key =
      check_platform_public_key(Map.get(options, :platform_public_key), client)

    if not is_nil(platform_public_id) and not is_binary(platform_public_id) do
      raise ArgumentError,
            "Bad platform_public_id: #{inspect(platform_public_id)} option for #{inspect(client)}"
    end

    if is_binary(platform_public_id) and is_nil(platform_public_key) do
      raise ArgumentError,
            "Please set platform_public_key option when platform_public_id is set for #{inspect(client)}"
    end

    if is_nil(platform_public_id) and not is_nil(platform_public_key) do
      raise ArgumentError,
            "Please set platform_public_id option when platform_public_key is set for #{inspect(client)}"
    end

    public_key = X509.PublicKey.derive(private_key)

    %{options | api_secret_key: api_secret_key, api_secret_v2_key: api_secret_v2_key}
    |> Map.put(:private_key, Macro.escape(private_key))
    |> Map.put(:public_key, Macro.escape(public_key))
    |> Map.put(:platform_public_id, Macro.escape(platform_public_id))
    |> Map.put(:platform_public_key, Macro.escape(platform_public_key))
  end

  defp check_api_key(nil, fun_name, client) do
    raise ArgumentError, "Please set #{fun_name} option for #{inspect(client)}"
  end

  defp check_api_key(api_key, fun_name, _client) when is_binary(api_key) do
    quote do
      def unquote(fun_name)(), do: unquote(api_key)
    end
  end

  defp check_api_key(api_key, fun_name, client) when is_atom(api_key) or is_tuple(api_key) do
    with :not_handle <-
           Utils.handle_env_option(client, fun_name, api_key) do
      raise ArgumentError,
            "Bad #{fun_name}: #{inspect(api_key)} option for #{inspect(client)}"
    end
  end

  defp check_api_key(api_key, fun_name, client) do
    raise ArgumentError,
          "Bad #{fun_name}: #{inspect(api_key)} option for #{inspect(client)}"
  end

  defp check_platform_public_key(nil, _client), do: nil

  defp check_platform_public_key(pem_file, client) when is_binary(pem_file) do
    parse_platform_public_key(pem_file, client)
  end

  defp check_platform_public_key(pem_file, client) do
    case check_pem_file(pem_file) do
      {:bad_arg, bad} ->
        raise ArgumentError,
              "Bad platform_public_key: #{inspect(bad)} option for #{inspect(client)}"

      pem_file ->
        pem_file |> read_pem!() |> parse_platform_public_key(client)
    end
  end

  defp parse_platform_public_key(pem, client) do
    case X509.PublicKey.from_pem(pem) do
      {:ok, public_key} ->
        public_key

      {:error, reason} ->
        raise ArgumentError,
              "Bad platform_public_key: #{inspect(reason)} option for #{inspect(client)}"
    end
  end

  defp read_pem!({:binary, binary}), do: binary
  defp read_pem!({:file, path}), do: File.read!(path)
  defp read_pem!({:app_dir, app, path}), do: Application.app_dir(app, path) |> File.read!()

  defp check_pem_file(quoted = {:{}, opts, list}) when is_list(opts) and is_list(list) do
    {pem_file, _} = Code.eval_quoted(quoted)
    if check_pem_file?(pem_file), do: pem_file, else: {:bad_arg, pem_file}
  end

  defp check_pem_file(pem_file) when is_tuple(pem_file) do
    if check_pem_file?(pem_file), do: pem_file, else: {:bad_arg, pem_file}
  end

  defp check_pem_file(nil), do: :unset
  defp check_pem_file(pem_file), do: {:bad_arg, pem_file}

  defp check_pem_file?({:app_dir, app, path}) when is_atom(app) and is_binary(path),
    do: Application.app_dir(app, path) |> File.exists?()

  defp check_pem_file?({:file, path}) when is_binary(path), do: File.exists?(path)
  defp check_pem_file?({:binary, binary}) when is_binary(binary), do: true
  defp check_pem_file?(_), do: false
end
