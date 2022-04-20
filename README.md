# SnakeBot

## Configuration
Run mix deps.get to install dependences of this project.

Edit or create your config file at /config/config.exs. To run Nostrum you need the following fields:

```elixir
import Config
config :nostrum,
  token: "666" # The token of your bot as a string
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `discord_bot` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:discord_bot, "~> 0.1.0"}
  ]
end


```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/discord_bot>.

