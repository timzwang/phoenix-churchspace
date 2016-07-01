defmodule Churchspace.PostController do
  use Churchspace.Web, :controller

  alias Churchspace.Event
  alias Churchspace.Post

  def action(conn, _) do
    conn =
      case conn.params do
        %{"event_id" => id} ->
          assign(conn, :event, Repo.get!(Event, id))
        _ ->
          conn
      end
    apply(__MODULE__, action_name(conn), [conn, conn.params])
  end

  defp event_posts(nil), do: Post
  defp event_posts(%Event{} = event), do: assoc(event, :posts)

  def index(conn, _params) do
    posts = Repo.all(event_posts(conn.assigns[:event]))
    render(conn, "index.html", posts: posts)
  end

  def new(conn, _params) do
    changeset = Post.changeset(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    changeset = Post.changeset(%Post{}, post_params)

    case Repo.insert(changeset) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: post_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Repo.get!(event_posts(conn.assigns[:event]), id)
    render(conn, "show.html", post: post)
  end

  def edit(conn, %{"id" => id}) do
    post = Repo.get!(event_posts(conn.assigns[:event]), id)
    changeset = Post.changeset(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Repo.get!(event_posts(conn.assigns[:event]), id)
    changeset = Post.changeset(post, post_params)

    case Repo.update(changeset) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: post_path(conn, :show, post))
      {:error, changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Repo.get!(event_posts(conn.assigns[:event]), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: post_path(conn, :index))
  end
end
