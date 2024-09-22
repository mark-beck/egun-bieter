defmodule EgunBieter.Store do

  def start do
    if (File.exists?("store.data")) do
      :ets.file2tab(~c"store.data")
    else
      :ets.new(:articles, [:named_table, :public])
    end


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
    backup_data()
  end

  def add art do
    :ets.insert_new(:articles, {art.id, art})
    backup_data()
  end

  def remove id do
    :ets.delete(:articles, id)
    backup_data()
  end

  defp backup_data do
    # first, rename old backup if it exists
    if File.exists?("store.data") do
      File.cp("store.data", "store.backup")
      File.rm("store.data")
    end

    :ets.tab2file(:articles, ~c"store.data")
  end
end
