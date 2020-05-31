defmodule CollabexWeb.PageController do
  use CollabexWeb, :controller

  def index(conn, _) do
    render(conn, "index.html")
  end

  def show(conn, %{"topic" => topic}) do
    render(conn, "show.html", topic: topic)
  end
end
