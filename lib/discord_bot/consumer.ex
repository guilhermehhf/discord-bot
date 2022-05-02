defmodule DiscordBot.Consumer do
  use Nostrum.Consumer
  alias Nostrum.Api

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    Consumer.start_link(__MODULE__)

  end

  def handle_event({:MESSAGE_CREATE,msg,_ws_state}) do
    cond do
      #1.
      # String.starts_with?(msg.content, "!comparar pib ") -> handlePib(msg)
      # msg.content == "!comparar pib" -> Api.create_message(msg.channel_id,"Digite **!comparar pib <identificador-do-pais1>-<identificador-do-pais2>** exemplo 'BR' para Brasil, use **!identificadores paises** para ver a lista")
      #2.
      String.starts_with?(msg.content, "!capital país ") -> handleHistorico(msg)
      msg.content == "!capital país" -> Api.create_message(msg.channel_id, "Digite **!capital país <identificador-do-pais>** exemplo 'BR' para Brasil, use **!identificadores paises** para ver a lista")
      #3.
      String.starts_with?(msg.content, "!proximo feriado ") ->  handleProximoFeriado(msg)
      msg.content == "!proximo feriado" -> Api.create_message(msg.channel_id, "Digite **!proximo feriado <UF>**")
      #4.
      String.starts_with?(msg.content, "!ranking nomes ") -> handleRankingNomes(msg)
      msg.content == "!ranking nomes" -> Api.create_message(msg.channel_id,"Digite **!ranking nomes <decada> exemplos: 1960 ou 1970**")
      #5.
      String.starts_with?(msg.content, "!pessoas com nome ") -> handleQuantidadePessoasComNome(msg)
      msg.content == "!pessoas com nome" -> Api.create_message(msg.channel_id,"Digite **!pessoas com nome <nome>**")
       #6.
       String.starts_with?(msg.content, "!qtd cidades ") -> handleQuantidadeCidades(msg)
       msg.content == "!qtd cidades" -> Api.create_message(msg.channel_id,"Digite **!qtd cidades <UF>**")
        #7.
      msg.content == "!identificadores uf" -> handleIdentificadoresUF(msg)
      #8.
      String.starts_with?(msg.content, "!pesquisar atv economica ") -> handlePesquisarAtvEcon(msg)
      msg.content == "!pesquisar atv economica" -> Api.create_message(msg.channel_id,"Digite **!pesquisar atv economica<atividade-economica>**")
      #9.
      String.starts_with?(msg.content, "!comparar aqi ") -> handleQualidadeAr(msg)
      msg.content == "!comparar aqi" -> Api.create_message(msg.channel_id,"Digite **!comparar aqi <país1>,<país2>** para comparar a qualidade do ar entre dois países")
      #10.
      msg.content == "!noticia" -> handleNoticia(msg)

      msg.content == "!comandos" -> handleComandos(msg)
      true -> :ignore
    end
  end

  defp handleComandos(msg) do
    Api.create_message(msg.channel_id, ">>> !pib\n!historico país\n!pessoas com nome\n!identificadores uf\n!ranking nomes\n!noticia")
  end

  #1. comparar pib {pais1}-{pais2}
  defp handlePib(msg) do
    aux = String.split(msg.content, " ", parts: 3)
    ids = String.split(Enum.fetch!(aux, 2), "-", parts: 2)
    resp = HTTPoison.get!("https://servicodados.ibge.gov.br/api/v1/paises/#{Enum.fetch!(ids, 0)}|#{Enum.fetch!(ids, 1)}/indicadores/77823")
    {:ok, list} = Poison.decode(resp.body)
    list = Enum.fetch!(list, 0)["series"] 
    list = Enum.map(list, fn pais -> formatObject(pais, msg) end)
    pais1 = Enum.find(list, fn pais -> pais[:id] == Enum.fetch!(ids, 0) end)
    pais2 = Enum.find(list, fn pais -> pais[:id] == Enum.fetch!(ids, 1) end)
    Api.create_message(msg.channel_id, "#{formatMessage(pais1, pais2)}")
  end

  defp formatObject(pais, msg) do
   {:ok, pibByYear} = Enum.fetch(pais["serie"], -2)
   {:ok, pibValue} = Enum.fetch(Map.values(pibByYear), 0)
    retorno = %{
      id: pais["pais"]["id"],
     nome: pais["pais"]["nome"], 
     pib: pibValue}
  end

  defp formatMessage(pais1, pais2) do
    porcentagem = String.to_float(pais1[:pib])/String.to_float(pais2[:pib]) * 100.00
    retorno = " O pib per capita do #{pais1["nome"]} é #{porcentagem}% do mesmo indicador do #{pais2["nome"]}"
    #retorno = "#{Float.parse(pais2[:pib])}"
  end

  #2. historia {pais}
  defp handleHistorico(msg) do
    aux = String.split(msg.content, " ", parts: 3)
    id = Enum.fetch!(aux, 2)

    resp = HTTPoison.get!("https://servicodados.ibge.gov.br/api/v1/paises/#{id}")

    {:ok, list} = Poison.decode(resp.body)
    map = Enum.fetch!(list, 0)
    Api.create_message(msg.channel_id, "#{map["governo"]["capital"]["nome"]}")
  end


  #3.proximo feriado {UF}:
  defp handleProximoFeriado(msg) do
    aux = String.split(msg.content, " ", parts: 3)
    estado = Enum.fetch!(aux, 2)
    data = Date.utc_today
    nextYear = data.year + 1
    respAnoAtual = HTTPoison.get!("https://api.invertexto.com/v1/holidays/#{data.year}?token=755|FpPjNcxNstET6qdFcUwYucpEDmg2Njer&state=#{estado}")
    respAnoPost = HTTPoison.get!("https://api.invertexto.com/v1/holidays/#{nextYear}?token=755|FpPjNcxNstET6qdFcUwYucpEDmg2Njer&state=#{estado}")
    {:ok, list1} = Poison.decode(respAnoAtual.body)
    {:ok, list2} = Poison.decode(respAnoPost.body)
    listTotal = Enum.concat(list1, list2)
    
    feriado = Enum.find(listTotal, nil, fn feriado -> compareDates(data, feriado["date"]) end )
    Api.create_message(msg.channel_id, ">>> #{feriado["date"]} - #{feriado["name"]} ")
 
  end

  defp compareDates(date1, date2) do
      {:ok, dateFeriado} = Date.from_iso8601(date2)
      Date.compare(date1, dateFeriado) == :lt
  end

  #4. ranking nome dec {década}:
  defp handleRankingNomes(msg) do
    aux = String.split(msg.content, " ", parts: 3)
    decada = Enum.fetch!(aux, 2)
    resp = HTTPoison.get!("https://servicodados.ibge.gov.br/api/v2/censos/nomes/ranking/?decada=#{decada}")

    {:ok, list} = Poison.decode(resp.body)

    if Enum.count(list) != 0 do
      map = Enum.fetch!(list, 0)["res"]
      rank = Enum.map(map, fn campo -> "**Nome: #{campo["nome"]}**\nQuantidade: #{campo["frequencia"]}\nRank: #{campo["ranking"]}\n" end)
      Api.create_message(msg.channel_id, ">>> #{rank}")
    else
      Api.create_message(msg.channel_id, "Digite **!ranking nomes <decada> exemplos: 1960 ou 1970**")
    end

  end

  #5. obter qtd nome {nome}:
  defp handleQuantidadePessoasComNome(msg) do
    aux = String.split(msg.content, " ", parts: 4)
    nome = Enum.fetch!(aux, 3)

    resp = HTTPoison.get!("https://servicodados.ibge.gov.br/api/v2/censos/nomes/#{nome}")

    {:ok, list} = Poison.decode(resp.body)

    if Enum.count(list) != 0 do
      map = Enum.fetch!(list, 0)["res"]
      result = Enum.fetch!(map,Enum.count(map)-1)
      periodo = String.replace(String.replace(result["periodo"], "[",""),",","-")
      Api.create_message(msg.channel_id, "*Periodo:* #{periodo}\n*Frequência:* #{result["frequencia"]}")
    else
      Api.create_message(msg.channel_id, "Digite **!pessoas com nome <nome>**")
    end
  end

   #6. qtd cidades {UF}:
   defp handleQuantidadeCidades(msg) do
    aux = String.split(msg.content, " ", parts: 3)
    uf = Enum.fetch!(aux, 2)
    resp = HTTPoison.get!("https://servicodados.ibge.gov.br/api/v1/localidades/estados/#{uf}/municipios")
    {:ok, list} = Poison.decode(resp.body)
    qtd_cidades = Enum.count(list)
    Api.create_message(msg.channel_id, ">>> #{qtd_cidades}")
  end

  #7.obter siglas dos estados:
  defp handleIdentificadoresUF(msg) do
    resp = HTTPoison.get!("https://servicodados.ibge.gov.br/api/v1/localidades/estados")

    {:ok, list} = Poison.decode(resp.body)
   
    nomes_siglas = Enum.map(list, fn estado_stats -> "**#{estado_stats["id"]}** - **#{estado_stats["sigla"]}** - *#{estado_stats["nome"]}*\n " end)
  
    Api.create_message(msg.channel_id, ">>> #{nomes_siglas}")
  end

  #8.pesquisar atv econ {atividade-economica}:
  defp handlePesquisarAtvEcon(msg) do
    aux = String.split(msg.content, " ", parts: 4)
    txt = Enum.fetch!(aux, 3)
    resp = HTTPoison.get!("https://servicodados.ibge.gov.br/api/v2/cnae/subclasses")
    {:ok, list} = Poison.decode(resp.body)
    subclasses = Enum.filter(list, fn subclasse -> String.contains?("O CARRO DO PEDRO É PRETO", String.upcase(txt)) end)
    retorno = Enum.map(subclasses, fn subclasse -> "**#{subclasse["id"]} - #{subclasse["descricao"]}**\n"end)
    Api.create_message(msg.channel_id, retorno)
  end

  
  #9.
  defp handleQualidadeAr(msg) do
    aux = String.split(msg.content, " ", parts: 3)
    [pais1,pais2] = String.split(Enum.fetch!(aux, 2), ",")

    resp1 = HTTPoison.get!("http://api.waqi.info/feed/#{String.downcase(pais1)}/?token=37c316562d2bc43d756ef7c92de8cb5dae665864")
    resp2 = HTTPoison.get!("http://api.waqi.info/feed/#{String.downcase(pais2)}/?token=37c316562d2bc43d756ef7c92de8cb5dae665864")

    {:ok, list1} = Poison.decode(resp1.body)
    {:ok, list2} = Poison.decode(resp2.body)

    if list1["status"] == "ok" and list2["status"] == "ok" do
      cidade1 = list1["data"]["city"]
      cidade2 = list2["data"]["city"]
      cond do
        list1["data"]["aqi"] > list2["data"]["aqi"] -> Api.create_message(msg.channel_id, "A qualidade do ar do cidade **#{cidade2["name"]}** com *aqi = #{list2["data"]["aqi"]}* é melhor que a da cidade **#{cidade1["name"]}** com aqi = #{list1["data"]["aqi"]}\nLinks:\n#{cidade1["url"]}\n#{cidade2["url"]}")
        list1["data"]["aqi"] < list2["data"]["aqi"] -> Api.create_message(msg.channel_id, "A qualidade do ar da cidade **#{cidade1["name"]}** com *aqi = #{list1["data"]["aqi"]}* é melhor que a da cidade **#{cidade2["name"]}** com aqi = #{list2["data"]["aqi"]}\nLinks:\n#{cidade1["url"]}\n#{cidade2["url"]}")
        true -> IO.puts(list1["data"]["aqi"])
      end
    else
      Api.create_message(msg.channel_id, "Algum dos países passados no comando é inválido")
    end
  end



  #10.uma notícia do IBGE:
	# *Pegar aleatóriamente uma das 60 ultimas notícias do IBGE
  defp handleNoticia(msg) do
    resp = HTTPoison.get!("http://servicodados.ibge.gov.br/api/v3/noticias/?tipo=noticia")

    {:ok, list} = Poison.decode(resp.body)
    random_number = :rand.uniform(60)
    noticia = Enum.fetch!(list["items"], random_number)
    titulo = noticia["titulo"]
    data = Enum.fetch!(String.split(noticia["data_publicacao"], " "),0)
    Api.create_message(msg.channel_id, "Titulo: #{titulo}\nData: #{data}\n #{noticia["link"]}")
  end



  def handle_event(_event) do
    :noop
  end

  defp getIndicesEstados() do
    resp = HTTPoison.get!("https://servicodados.ibge.gov.br/api/v1/localidades/estados")
    {:ok, list} = Poison.decode(resp.body)
    indiceEstados = []
    Enum.each(list, fn x -> indiceEstados ++[{x["sigla"],x["id"]}]  end)
    indiceEstados
  end
end
