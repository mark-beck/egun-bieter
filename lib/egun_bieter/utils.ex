defmodule EgunBieter.Utils do

  def parse_money str do
    # check for right format
    cond do
      str |> String.graphemes |> Enum.all?(fn e -> Enum.member?(["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", ","], e) end) ->
        parts = str |> String.split(",")
        if length(parts) != 2, do: throw "more than 2 parts found"
        { :ok, parts |> Enum.at(0), parts |> Enum.at(1) }
      str |> String.graphemes |> Enum.all?(fn e -> Enum.member?(["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "."], e) end) ->
        parts = str |> String.split(".")
        if length(parts) != 2, do: throw "more than 2 parts found"
        { :ok, parts |> Enum.at(0), parts |> Enum.at(1) }
      str |> String.graphemes |> Enum.all?(fn e -> Enum.member?(["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"], e) end) ->
        { :ok, str, "00"}
      true -> throw "only numbers and , or . allowed"
    end
  catch
    m -> {:err, m}
  end

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
