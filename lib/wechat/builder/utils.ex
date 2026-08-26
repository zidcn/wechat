defmodule WeChat.Builder.Utils do
  @moduledoc false
  require Logger

  def gen_code_name(client) do
    client |> to_string() |> String.split(".") |> List.last() |> String.downcase()
  end

  def check_env_option?(:runtime_env), do: true
  def check_env_option?({:runtime_env, app}) when is_atom(app), do: true
  def check_env_option?(:compile_env), do: true
  def check_env_option?({:compile_env, app}) when is_atom(app), do: true
  def check_env_option?(_), do: false

  def handle_env_option(_client, key, :runtime_env) do
    quote do
      def unquote(key)(),
        do: Application.fetch_env!(:wechat, __MODULE__) |> Keyword.fetch!(unquote(key))
    end
  end

  def handle_env_option(_client, key, {:runtime_env, app}) do
    quote do
      def unquote(key)(), do: Application.fetch_env!(unquote(app), unquote(key))
    end
  end

  def handle_env_option(client, key, :compile_env) do
    value = Application.fetch_env!(:wechat, client) |> Keyword.fetch!(key)

    quote do
      def unquote(key)(), do: unquote(value)
    end
  end

  def handle_env_option(client, key, {:compile_env, app}) do
    value = Application.fetch_env!(app, client) |> Keyword.fetch!(key)

    quote do
      def unquote(key)(), do: unquote(value)
    end
  end

  def handle_env_option(_, _, _), do: :not_handle

  def warn_unknown_option(options, known_keys, client) when is_list(options) do
    do_warn_unknown_option(Keyword.keys(options) -- known_keys, client)
  end

  def warn_unknown_option(options, known_keys, client) when is_map(options) do
    do_warn_unknown_option(Map.keys(options) -- known_keys, client)
  end

  defp do_warn_unknown_option(unknown_keys, client) do
    Enum.each(unknown_keys, fn key ->
      Logger.warning("Found unknown option: #{key} for #{client}")
    end)
  end
end
