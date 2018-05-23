defmodule RumblWeb.VideoControllerTest do
  use RumblWeb.ConnCase

  alias Rumbl.App
  alias Rumbl.App.Video
  alias Rumbl.Repo
  import Ecto.Query

  @valid_attrs %{url: "http://youtu.be", title: "vid", description: "a vid"}
  @update_attrs %{description: "some updated description", title: "some updated title", url: "some updated url"}
  @invalid_attrs %{title: "invalid", url: nil, description: nil}

  defp video_count(query), do: Repo.one(from v in query, select: count(v.id))

  def fixture(:video, user) do
    {:ok, video} = App.create_video(user, @valid_attrs)
    video
  end

  setup %{conn: conn} = config do
    if nil != config[:login_as] do
      user = insert_user(username: "max")
      conn = assign(build_conn(), :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      get(conn, video_path(conn, :new)),
      get(conn, video_path(conn, :index)),
      get(conn, video_path(conn, :show, "123")),
      get(conn, video_path(conn, :edit, "123")),
      put(conn, video_path(conn, :update, "123", %{})),
      post(conn, video_path(conn, :create, %{})),
      delete(conn, video_path(conn, :delete, "123"))
    ], fn conn -> 
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  describe "index" do
    @tag login_as: "max"
    test "lists all user's videos on index", %{conn: conn, user: user} do
      user_video = insert_video(user, title: "funny cats")
      other_video = insert_video(insert_user(username: "other"), title: "another video")
      conn = get conn, video_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Videos"
      assert String.contains?(conn.resp_body, user_video.title)
      refute String.contains?(conn.resp_body, other_video.title)
    end
  end

  describe "new video" do

    @tag login_as: "max"
    test "renders form", %{conn: conn} do
      conn = get conn, video_path(conn, :new)
      assert html_response(conn, 200) =~ "New Video"
    end
  end

  describe "create video" do

    @tag login_as: "max"
    test "creates user video and redirects", %{conn: default_conn, user: user} do
      conn = post default_conn, video_path(default_conn, :create), video: @valid_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == video_path(conn, :show, id)
      assert Repo.get_by!(Video, @valid_attrs).user_id == user.id

      conn = get default_conn, video_path(default_conn, :show, id)
      assert html_response(conn, 200) =~ "Show Video"
    end

    @tag login_as: "max"
    test "does not create video and renders errors when data is invalid", %{conn: conn} do
      count_before = video_count(Video)
      conn = post conn, video_path(conn, :create), video: @invalid_attrs
      assert html_response(conn, 200) =~ "check the errors"
      assert video_count(Video) == count_before
    end
  end

  describe "authorization_logic" do
    
    @tag login_as: "max"
    test "authorizes actions against access by other users", %{user: owner, conn: conn} do
      video = insert_video(owner, @valid_attrs)
      non_owner = insert_user(username: "sneaky")
      conn = assign(conn, :current_user, non_owner)

      assert_error_sent :not_found, fn ->
        get(conn, video_path(conn, :show, video))
      end
      assert_error_sent :not_found, fn ->
        get(conn, video_path(conn, :edit, video))
      end
      assert_error_sent :not_found, fn ->
        put(conn, video_path(conn, :update, video, video: @valid_attrs))
      end
      assert_error_sent :not_found, fn ->
        delete(conn, video_path(conn, :delete, video))
      end
    end
  end

  describe "edit video" do
    setup [:create_video]

    @tag login_as: "max"
    test "renders form for editing chosen video", %{conn: conn, video: video} do
      conn = get conn, video_path(conn, :edit, video)
      assert html_response(conn, 200) =~ "Edit Video"
    end
  end

  describe "update video" do
    setup [:create_video]

    @tag login_as: "max"
    test "redirects when data is valid", %{conn: default_conn, video: video} do
      conn = put default_conn, video_path(default_conn, :update, video), video: @update_attrs
      refute redirected_to(conn) == video_path(conn, :show, video)

      conn = get default_conn, video_path(default_conn, :show, video)
      assert html_response(conn, 200) =~ "some updated description"
    end

    @tag login_as: "max"
    test "renders errors when data is invalid", %{conn: conn, video: video} do
      conn = put conn, video_path(conn, :update, video), video: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Video"
    end
  end

  describe "delete video" do
    setup [:create_video]

    @tag login_as: "max"
    test "deletes chosen video", %{conn: default_conn, video: video} do
      conn = delete default_conn, video_path(default_conn, :delete, video)
      assert redirected_to(conn) == video_path(conn, :index)
      assert_error_sent 404, fn ->
        get default_conn, video_path(default_conn, :show, video)
      end
    end
  end

  defp create_video(%{user: user}) do
    video = fixture(:video, user)
    {:ok, video: video}
  end
end
