defmodule DiscordBot.Consumer do
  use Nostrum.Consumer
  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end
  def handle_event({:MESSAGE_CREATE,msg,_ws_state}) do
    cond do
      String.starts_with?(msg.content, "!personagem ") -> handlePersonagem(msg)
      msg.content == "!personagem" -> Api.create_message(msg.channel_id, "Digite **!personagem <id-do-personagem>**")

      String.starts_with?(msg.content, "!pong") -> Api.create_message(msg.channel_id, "ping")
      true -> :ignore
    end
  end

  defp handlePersonagem(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    id = Enum.fetch!(aux, 1)

    resp = HTTPoison.get!("https://api.disneyapi.dev/characters/#{id}")

    {:ok, map} = Poison.decode(resp.body)

    Api.create_message(msg.channel_id, Enum.join(map["tvShows"], ", "))

  end
  def handle_event(_event) do
    :noop
  end
end
