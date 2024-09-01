defmodule EgunBieter.EgunApi do
  require Logger

  defp regex_match_and_merge({:ok, captures}, regex, body) do
    capture = Regex.named_captures(regex, body)
    case capture do
      nil ->
        id = "#{System.unique_integer([:positive, :monotonic])}-#{:os.system_time(:nanosecond)}"
        Logger.error([message: "Couldn't match regex with body, dumping body to file", regex: regex, file_id: id])
        File.write("log/dump_#{id}", body, [:write])
        {:error , "Couldn't match #{Regex.source(regex)}, logging specifics"}
      _ -> {:ok, Map.merge(captures, capture)}
    end
  end

  defp regex_match_and_merge({:error, e}, _, _) do
    {:error, e}
  end

  def get_id id do

    body = HTTPoison.get!("https://egun.de/market/item.php?id=#{id}").body
    result = {:ok, %{}}
    |> regex_match_and_merge(~r/Aktueller Preis<\/td>\r\n.*<td><b>(?<preis>.*)<\/b><\/td>/, body)
    |> regex_match_and_merge(~r/Restzeit<\/td>\r\n.*<td nowrap><b.*>(?<restzeit>.*)<\/b>.*\(akt. Zeit: (?<zeit>.*)\)[<\/td>|.*<\/span>]/, body)
    |> regex_match_and_merge(~r/Auktionsdauer<\/td>\r\n.*<td.*>(?<dauer>.*)<\/td>/, body)

    captures = case result do
      {:ok, captures} -> captures
      {:error, message} -> raise(EgunBieterWeb.Exceptions.PlugException, plug_status: 400, message: message)
    end


    last_bidder = Regex.named_captures(~r/H&ouml;chstbieter<\/td>\r\n.*<td><b class="link">(?<bieter>.*)&nbsp/, body)
    captures = if last_bidder do
      Map.merge(last_bidder, captures)
    else
      captures
    end

    time = captures["zeit"] |> EgunBieter.Utils.parse_datetime
    rest_time = captures["restzeit"] |> EgunBieter.Utils.parse_duration()

    end_time = NaiveDateTime.shift(time, rest_time)

    timeshift = NaiveDateTime.diff(NaiveDateTime.local_now(), time)

    %{
      id: id,
      last_bidder: captures["bieter"],
      duration: captures["dauer"],
      price: captures["preis"],
      end_time: end_time,
      timeshift: timeshift,
      access_time: time
    }

  end

  def send_bid article do
    # config = [proxy: {"127.0.0.1", 8080}, ssl: [verify: :verify_none]]
    config = []
    {euros, cents} = article.max_price
    Logger.info("sending bid for id: #{article.id}, amount: #{Enum.join(Tuple.to_list(article.max_price), ",")}")
    res = HTTPoison.post!("https://egun.de/market/bid.php",
      "id=#{article.id}&action=bid&bid=#{euros}%2C#{cents}&nick=#{article.username}&password=#{article.password}",
      %{
        "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:127.0) Gecko/20100101 Firefox/127.0",
        "Cookie" => "eGunSettings=a%3A1%3A%7Bs%3A3%3A%22SSL%22%3Bb%3A1%3B%7D; PHPSESSID=49b35c15a699fa70dbd1b3ed0a2e30b1",
        "Content-Type" => "application/x-www-form-urlencoded"
      },
      config)
      id = "#{System.unique_integer([:positive, :monotonic])}-#{:os.system_time(:nanosecond)}"
      File.write("log/dump_res_#{id}", res.body, [:write])

  end
end
