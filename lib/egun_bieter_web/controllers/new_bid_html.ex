defmodule EgunBieterWeb.NewBidHTML do
  use EgunBieterWeb, :html

  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(changeset: %{})
    }
  end

  def index(assigns) do
    ~H"""
    <form action={"/bid/new"} method="get">
      <input type="hidden" name="_csrf_token" value={"#{Plug.CSRFProtection.get_csrf_token()}"}>
      <.button>Neu</.button>
    </form>
    <div class="relative w-full overflow-auto">
    <table class="w-full caption-bottom text-sm">
      <thead class="[&amp;_tr]:border-b">
        <tr class="border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted">
          <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground [&amp;:has([role=checkbox])]:pr-0">ID</th>
          <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground [&amp;:has([role=checkbox])]:pr-0">Maximaler Betrag</th>
          <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground [&amp;:has([role=checkbox])]:pr-0">Endzeit</th>
          <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground [&amp;:has([role=checkbox])]:pr-0">Aktiv</th>
        </tr>
      </thead>
      <tbody class="[&amp;_tr:last-child]:border-0">
        <%= for {_id, entry} <- @items do %>
          <tr class="border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted">
            <td class="p-4 align-middle font-medium"><a href={"/bid/#{entry.id}"}><%= entry.id %></a></td>
            <td class="p-4 align-middle"><%= Enum.join(Tuple.to_list(entry.max_price), ",") %></td>
            <td class="p-4 align-middle"><%= NaiveDateTime.to_string entry.end_time %></td>
            <td class="p-4 align-middle"><%= entry.active %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    </div>
    """
  end

  def new(assigns) do
    ~H"""
    <.form :let={f} action={~p"/bid/new"}>
      ID:
      <.input field={f[:id]} />
      Maximaler Betrag in Euro:
      <.input field={f[:max_price]} />
      Zeit vor Auktionsschluss in sec:
      <.input field={f[:buy_before]} />
      Nutzername:
      <.input field={f[:username]} />
      Passwort:
      <.input field={f[:password]} />
      <.button>
        Submit
      </.button>
    </.form>
    """
  end

  def article(assigns) do
    ~H"""
    <a href="/bid">zurück</a>
    <h1>Artikel</h1>
    <table class="table-auto">
      <tbody>
          <tr>
            <td>ID</td>
            <td><%= @article.id %></td>
          </tr>
          <tr>
            <td>Letzter Zugriff</td>
            <td><%= NaiveDateTime.to_string @article.access_time %></td>
          </tr>
          <tr>
            <td>Aktiv</td>
            <td><%= @article.active %></td>
          </tr>
          <tr>
            <td>Abgegeben</td>
            <td><%= @article.bought %></td>
          </tr>
          <tr>
            <td>Derzeitiger Betrag</td>
            <td><%= @article.price %></td>
          </tr>
          <tr>
            <td>Maximaler Betrag</td>
            <td><%= Enum.join(Tuple.to_list(@article.max_price), ",") %> EUR</td>
          </tr>
          <tr>
            <td>Auktionsende</td>
            <td><%= NaiveDateTime.to_string @article.end_time %></td>
          </tr>
          <tr>
            <td>Kaufzeitpunkt</td>
            <td><%= NaiveDateTime.add(@article.end_time, -@article.buy_before) %></td>
          </tr>
          <tr>
            <td>Sekunden vor Ende</td>
            <td><%= @article.buy_before %></td>
          </tr>
          <tr>
            <td>Nutzer</td>
            <td><%= @article.username %></td>
          </tr>
      </tbody>
    </table>
    <form action={"/bid/#{@article.id}/refresh"} method="post">
      <input type="hidden" name="_csrf_token" value={"#{Plug.CSRFProtection.get_csrf_token()}"}>
      <.button name="foo" value="foo">Refresh</.button>
    </form>
    <%= if not @article.active do %>
    <form action={"/bid/#{@article.id}/update"} method="post">
      <input type="hidden" name="_csrf_token" value={"#{Plug.CSRFProtection.get_csrf_token()}"}>
      <.button name="active" value="true">Aktivieren</.button>
    </form>
    <% end %>
    <%= if @article.active do %>
    <form action={"/bid/#{@article.id}/update"} method="post">
      <input type="hidden" name="_csrf_token" value={"#{Plug.CSRFProtection.get_csrf_token()}"}>
      <.button name="active" value="false">Deaktivieren</.button>
    </form>
    <% end %>
    <form action={"/bid/#{@article.id}/delete"} method="post">
      <input type="hidden" name="_csrf_token" value={"#{Plug.CSRFProtection.get_csrf_token()}"}>
      <.button name="delete" value="">Löschen</.button>
    </form>


    """
  end


end
