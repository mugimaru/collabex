defmodule CollabexWeb.PageController do
  use CollabexWeb, :controller

  def show(conn, %{"topic" => topic}) do
    render(conn, "show.html", topic: topic)
  end
end
