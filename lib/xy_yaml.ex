defmodule XyYaml do
  @moduledoc """
  Documentation for XyYaml.
  """
  # phoenix project name
  def phx_name, do: Application.get_env(:xy_yaml, :phx_name) || :xy_yaml
  # origin yaml file save directory
  def file_dir, do: Application.get_env(:xy_yaml, :file_dir) || "/priv/yamls"

  @force_replace_flag "__force__"
  @doc """
  新旧数据合并,
    仅当changes中同级的键值类型与origin一致时，合并的时候使用changes的键值对
    在changes中，同级的键值类型与origin不一致、键在origin中不存在时，合并时使用origin的键值对
    在同级的changes中，origin包含键"__force__"，合并时使用origin的键值对，参照例子3

  ## Examples

    iex> origin=%{"k1" => %{"k2" => %{"k3" => %{"k4" => "v4"}}}}
    ...> changes=nil
    ...> XyYaml.merge(changes,origin)
    %{"k1" => %{"k2" => %{"k3" => %{"k4" => "v4"}}}}

    iex> origin=%{"k1" => %{"k2" => %{"k3" => %{"k4" => "v4"}}}, "k2" => "v2"}
    ...> changes=%{"k1" => %{"k2" => %{"k3" => %{"k4" => "v41", "k5" => "k5"}}}, "k2" => 1}
    ...> XyYaml.merge(changes,origin)
    %{"k1" => %{"k2" => %{"k3" => %{"k4" => "v41"}}}, "k2" => "v2"}

    iex> origin =%{"k1" => %{"__force__" => true, "k2" => "force_replace", "k3"=>%{"k4"=>"v4","k5"=>"v5"}}}
    ...> changes=%{"k1" => %{"k2" => "v2", "k3"=>%{"k4"=>"v4","k5"=>"changes"}}}
    ...> XyYaml.merge(changes,origin)
    %{"k1" => %{"k2" => "force_replace", "k3"=>%{"k4"=>"v4","k5"=>"v5"}}}

  """
  def merge(changes, origin) when is_map(origin) do
    merge(changes || %{}, origin, Map.keys(origin) |> List.delete(@force_replace_flag))
  end

  def merge(changes, _origin, []) do
    changes
  end

  def merge(changes, origin, [key | keys]) do
    changes = Map.take(changes, Map.keys(origin))
    {is_force, origin} = Map.pop(origin, @force_replace_flag)
    origin_kv = origin[key]
    changes_kv = changes[key]

    cond do
      is_force == true ->
        merge(origin, origin, [])

      Map.has_key?(changes, key) == false ->
        Map.put(changes, key, origin_kv)
        |> merge(origin, keys)

      data_type_equal?(changes_kv, origin_kv) == false ->
        Map.put(changes, key, origin_kv)
        |> merge(origin, keys)

      is_map(origin_kv) ->
        origin_kv_k =
          Map.keys(origin_kv)
          |> List.delete(@force_replace_flag)

        Map.put(changes, key, merge(changes_kv, origin_kv, origin_kv_k))
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

  # 判断值数据类型是否一致
  defp data_type_equal?(changes_kv, origin_kv) do
    type1 =
      changes_kv
      |> IEx.Info.info()
      |> List.first()

    type2 =
      origin_kv
      |> IEx.Info.info()
      |> List.first()

    type1 == type2
  end
end
