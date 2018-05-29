defmodule XyYaml do
  @moduledoc """
  Documentation for XyYaml.
  """
  # phoenix project name
  def phx_name, do: Application.get_env(:xy_yaml, :phx_name) || :xy_yaml
  # origin yaml file save directory
  def file_dir, do: Application.get_env(:xy_yaml, :file_dir) || "/priv/yamls"
  @doc """
  新旧数据合并,
    仅当changes中同级的键值类型与origin一致时，合并的时候使用changes的键值对
    在changes中，同级的键值类型与origin不一致、键在origin中不存在时，合并时使用origin的键值对

  ## Examples

    iex> origin=%{k1: %{k2: %{k3: %{k4: :v4}}}}
    ...> changes=nil
    ...> XyYaml.merge(changes,origin)
    %{k1: %{k2: %{k3: %{k4: :v4}}}}

    iex> origin=%{k1: %{k2: %{k3: %{k4: :v4}}},k2: :v2}
    ...> changes=%{k1: %{k2: %{k3: %{k4: :v41,k5: :k5}}},k2: 1}
    ...> XyYaml.merge(changes,origin)
    %{k1: %{k2: %{k3: %{k4: :v41}}},k2: :v2}
  """
  def merge(changes, origin) when is_map(origin) do
    merge(changes || %{}, origin, Map.keys(origin))
  end

  def merge(changes, _origin, []) do
    changes
  end

  def merge(changes, origin, [key | keys]) do
    changes = Map.take(changes, Map.keys(origin))

    cond do
      Map.has_key?(changes, key) == false ->
        Map.put(changes, key, origin[key])
        |> merge(origin, keys)

      IEx.Info.info(changes[key]) != IEx.Info.info(origin[key]) ->
        Map.put(changes, key, origin[key])
        |> merge(origin, keys)

      is_map(origin[key]) ->
        Map.put(changes, key, merge(changes[key], origin[key], Map.keys(origin[key])))
        |> merge(origin, keys)

      true ->
        merge(changes, origin, keys)
    end
  end

  @doc """
  读取配置
  """
  def read_from_file(filename) do
    Application.app_dir(phx_name())
    |> Path.join(file_dir())
    |> Path.join(filename)
    |> YamlElixir.read_from_file()
  end
end
