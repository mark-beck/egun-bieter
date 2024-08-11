defmodule EgunBieter.Sniper do
  alias EgunBieter.EgunApi
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    :timer.send_interval(1_000, :work)
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    do_recurrent_thing(state)
    {:noreply, state}
  end

  defp do_recurrent_thing(_state) do
    EgunBieter.Store.get_all
    |> Enum.map(fn {_, article} ->
      buydate = NaiveDateTime.add(article.end_time, -article.buy_before)
      if article.active and (not article.bought) and NaiveDateTime.before?(buydate, NaiveDateTime.local_now()) do
        EgunBieter.Store.update(%{article | bought: true})
        EgunApi.send_bid(article)
      end
    end)
  end

end
