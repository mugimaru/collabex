defmodule CollabexWeb.PageController do
  use CollabexWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
