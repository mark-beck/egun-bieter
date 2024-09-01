defmodule EgunBieterWeb.NewBidController do
  require Logger
  alias EgunBieter.Store
  alias EgunBieter.EgunApi
  use EgunBieterWeb, :controller

  def index(conn, _params) do
    items = Store.get_all()
    render(conn, :index, items: items)
  end

  def new(conn, _params) do
    render(conn, :new)
  end

  def article(conn, %{"id" => id}) do
    {:ok, article}  = Store.get(id)
    render(conn, :article, article: article)
  end

  def refresh(conn, %{"id" => id}) do
    Logger.info("refreshing article")
    refreshed_article = EgunApi.get_id(id)
    {:ok, old_article}  = Store.get(id)
    Store.update(Map.merge(old_article, refreshed_article))
    redirect(conn, to: ~p"/bid/#{id}")
  end

  def create(conn, params) do
    Logger.info("creating new article with params: #{inspect(params)}")
    article = EgunApi.get_id(params["id"])
    {:ok, euro, cent} = EgunBieter.Utils.parse_money(params["max_price"])
    article = Map.merge(article, %{
      max_price: {euro, cent},
      active: false,
      bought: false,
      buy_before: params["buy_before"] |> String.to_integer(),
      username: params["username"],
      password: params["password"]
    })
    Logger.info("creating new article: #{inspect(article)}")
    Store.add(article)
    redirect(conn, to: ~p"/bid/#{article.id}")
  end

  def update(conn, %{"id" => id} = params) do
    if Map.has_key?(params, "active") do
      active = if params["active"] == "true" do
        true
      else
        false
      end
      {:ok, old_article}  = Store.get(id)
      Store.update(Map.merge(old_article, %{active: active}))

    end

    redirect(conn, to: ~p"/bid/#{id}")
  end

  def redirect_index(conn, _params) do
    redirect(conn, to: ~p"/bid")
  end

  def delete(conn, %{"id" => id}) do
    Logger.info("deleting id: #{id}")
    Store.remove(id)
    redirect(conn, to: ~p"/bid/")
  end
end
