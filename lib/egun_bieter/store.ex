defmodule EgunBieter.Store do

  def start do
    :ets.new(:articles, [:named_table, :public])
  end

  def get_all do
    :ets.tab2list(:articles)
  end

  def get id do
    case :ets.lookup(:articles, id) do
      [{_, m}] -> {:ok, m}
      [] -> {:err, []}
    end
  end

  def update art do
    :ets.insert(:articles, {art.id, art})
  end

  def add art do
    :ets.insert_new(:articles, {art.id, art})
  end

  def remove id do
    :ets.delete(:articles, id)
  end

end
