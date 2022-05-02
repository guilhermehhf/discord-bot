# Information Bot

## Members: 
Guilherme Henrique Holanda Fernandes
Ingrid Moreira da Costa

## Commands:

**!capital {pais}:**
*O bot responde com a capital do país cuja sigla foi fornecida*
**!proximo feriado {UF}**
*O usuário é respondido com o próximo feriado municipal ou estadual e sua respectiva data*
**!ranking nome dec {década}:**
*Responde com o nome mais comum na década fornecida*
**!pessoas com nome {nome}:**
*Responde ao usuário a quantidade de pessoas batizadas com fornecido no comando na última década*
**!qtd cidades {UF}:**
*Responde ao usuário com a quantidade de cidades dentro da unidade de federação fornecida*
**!identificadores uf:**
*Fornece ao usuário as siglas de todos os estados brasileiros*
**!comparar aqi:**
*O usuário coloca dois países e é respondido qual deles tem o ar mais limpo.*
**!noticia**
*Retorna ao usuário aleatoriamente uma das últimas 60 notícias do IBGE*

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

