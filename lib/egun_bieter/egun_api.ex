defmodule EgunBieter.EgunApi do
  require Logger
  defmodule EgunBieter.EgunApi.Utils do

    def parse_datetime time_string do
      split = String.split(time_string, " ")
      date = split |> Enum.at(0) |> parse_date
      time = split |> Enum.at(1) |> parse_time
      NaiveDateTime.new!(date, time)
    end

    def parse_date date do
      split = String.split(date, ".")
      day = split |> Enum.at(0) |> String.to_integer
      month = split |> Enum.at(1) |> String.to_integer
      year = split |> Enum.at(2) |> String.to_integer
      Date.new!(year, month, day)
    end

    def parse_time time do
      split = String.split(time, ":")
      hour = split |> Enum.at(0) |> String.to_integer
      minute = split |> Enum.at(1) |> String.to_integer
      second = split |> Enum.at(2) |> String.to_integer
      Time.new!(hour, minute, second)
    end

    def parse_duration duration do
      split = String.split(duration, ", ")
      if length(split) == 2 do
        days = split |> Enum.at(0) |> String.split(" ") |> Enum.at(0) |> String.to_integer
        time_split = split |> Enum.at(1) |> String.split(":")
        hour = time_split |> Enum.at(0) |> String.to_integer
        minute = time_split |> Enum.at(1) |> String.to_integer
        second = time_split |> Enum.at(2) |> String.to_integer
        Duration.new!(day: days, hour: hour, minute: minute, second: second)
      else
        time_split = split |> Enum.at(0) |> String.split(":")
        hour = time_split |> Enum.at(0) |> String.to_integer
        minute = time_split |> Enum.at(1) |> String.to_integer
        second = time_split |> Enum.at(2) |> String.to_integer
        Duration.new!(hour: hour, minute: minute, second: second)
      end
    end

  end


  def get_id id do

    body = HTTPoison.get!("https://egun.de/market/item.php?id=#{id}").body
    captures = %{}
    captures = Regex.named_captures(~r/Aktueller Preis<\/td>\r\n.*<td><b>(?<preis>.*)<\/b><\/td>/, body) |> Map.merge(captures)
    captures = Regex.named_captures(~r/Restzeit<\/td>\r\n.*<td nowrap><b.*>(?<restzeit>.*)<\/b>.*\(akt. Zeit: (?<zeit>.*)\)[<\/td>|.*<\/span>]/, body) |> Map.merge(captures)
    captures = Regex.named_captures(~r/Auktionsdauer<\/td>\r\n.*<td.*>(?<dauer>.*)<\/td>/, body) |> Map.merge(captures)
    last_bidder = Regex.named_captures(~r/H&ouml;chstbieter<\/td>\r\n.*<td><b class="link">(?<bieter>.*)&nbsp/, body)
    captures = if last_bidder do
      Map.merge(last_bidder, captures)
    else
      captures
    end


    time = captures["zeit"] |> EgunBieter.EgunApi.Utils.parse_datetime
    rest_time = captures["restzeit"] |> EgunBieter.EgunApi.Utils.parse_duration()

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
    config = [proxy: {"127.0.0.1", 8080}, ssl: [verify: :verify_none]]

    Logger.info("sending bid for id: #{article.id}, amount: #{article.max_price}")
    HTTPoison.post!("https://egun.de/market/bid.php",
      "id=#{article.id}&action=bid&bid=#{article.max_price}%2C00&nick=#{article.username}&password=#{article.password}",
      %{
        "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:127.0) Gecko/20100101 Firefox/127.0",
        "Cookie" => "eGunSettings=a%3A1%3A%7Bs%3A3%3A%22SSL%22%3Bb%3A1%3B%7D; PHPSESSID=49b35c15a699fa70dbd1b3ed0a2e30b1",
        "Content-Type" => "application/x-www-form-urlencoded"
      },
      config)

  end



end
