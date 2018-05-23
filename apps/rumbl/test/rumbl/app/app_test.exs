defmodule Rumbl.AppTest do
  use Rumbl.DataCase

  alias Rumbl.App

  describe "videos" do
    alias Rumbl.App.Video

    @valid_attrs %{description: "some description", title: "some title", url: "some url"}
    @update_attrs %{description: "some updated description", title: "some updated title", url: "some updated url"}
    @invalid_attrs %{description: nil, title: nil, url: nil}

    setup do
      user = insert_user(username: "test")
      {:ok, user: user}
    end

    def video_fixture(user, attrs \\ %{}) do
      {:ok, video} =
        attrs
        |> Enum.into(@valid_attrs)
        |> (fn(a) -> App.create_video(user, a) end).()

      video
    end

    test "list_videos/0 returns all videos", %{user: user} do
      video = video_fixture(user)
      assert App.list_videos(user) == [video]
    end

    test "get_video!/1 returns the video with given id", %{user: user} do
      video = video_fixture(user)
      assert App.get_video!(user, video.id) == video
    end

    test "create_video/1 with valid data creates a video", %{user: user} do
      assert {:ok, %Video{} = video} = App.create_video(user, @valid_attrs)
      assert video.description == "some description"
      assert video.title == "some title"
      assert video.url == "some url"
    end

    test "create_video/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = App.create_video(user, @invalid_attrs)
    end

    test "update_video/2 with valid data updates the video", %{user: user} do
      video = video_fixture(user)
      assert {:ok, video} = App.update_video(video, @update_attrs)
      assert %Video{} = video
      assert video.description == "some updated description"
      assert video.title == "some updated title"
      assert video.url == "some updated url"
    end

    test "update_video/2 with invalid data returns error changeset", %{user: user} do
      video = video_fixture(user)
      assert {:error, %Ecto.Changeset{}} = App.update_video(video, @invalid_attrs)
      assert video == App.get_video!(user, video.id)
    end

    test "delete_video/1 deletes the video", %{user: user} do
      video = video_fixture(user)
      assert {:ok, %Video{}} = App.delete_video(video)
      assert_raise Ecto.NoResultsError, fn -> App.get_video!(user, video.id) end
    end

    test "change_video/1 returns a video changeset", %{user: user} do
      video = video_fixture(user)
      assert %Ecto.Changeset{} = App.change_video(video)
    end
  end
end
