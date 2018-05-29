# XyYaml

**Merges two maps into one. Resolving conflicts: First, `the keys of changes` must equal `the keys of origin`**,so the needless keys of changes will be drop. Second,use the key-value of origin when theirs key-type are diffrent or `the key of changes` doesn't exist in `origin`

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `xy_yaml` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:xy_yaml, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/xy_yaml](https://hexdocs.pm/xy_yaml).

Configuration
-------------
To use this lib, you should config variable (probably in
your app.config):

```elixir
config :xy_img,
  phx_name: :im_webserver, #phoenix project name
  file_dir: "priv/sets/" #origin yaml file save directory,default: "priv/yamls/"
```

## Simple Usage
```elixir
iex> origin=%{k1: %{k2: %{k3: %{k4: :v4}}},k2: :v2}
...> changes=%{k1: %{k2: %{k3: %{k4: :v41,k5: :k5}}},k2: 1}
...> XyYaml.merge(changes,origin)
%{k1: %{k2: %{k3: %{k4: :v41}}},k2: :v2}
```