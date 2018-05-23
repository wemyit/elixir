defmodule Rumbl.App do
  @moduledoc """
  The App context.
  """

  import Ecto.Query, warn: false
  import Ecto
  alias Rumbl.Repo

  alias Rumbl.App.Video

  @doc """
  Returns the list of videos.

  ## Examples

      iex> list_videos(user)
      [%Video{}, ...]

  """
  def list_videos(user) do
    Repo.all(user_videos(user))
  end

  @doc """
  Gets a single video.

  Raises `Ecto.NoResultsError` if the Video does not exist.

  ## Examples

      iex> get_video!(user, 123)
      %Video{}

      iex> get_video!(user, 456)
      ** (Ecto.NoResultsError)

  """
  def get_video!(user, id), do: Repo.get!(user_videos(user), id)

  @doc """
  Creates a video.

  ## Examples

      iex> create_video(user, %{field: value})
      {:ok, %Video{}}

      iex> create_video(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_video(user, attrs \\ %{}) do
    user
    |> build_assoc(:videos)
    |> Video.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a video.

  ## Examples

      iex> update_video(video, %{field: new_value})
      {:ok, %Video{}}

      iex> update_video(video, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Video.

  ## Examples

      iex> delete_video(video)
      {:ok, %Video{}}

      iex> delete_video(video)
      {:error, %Ecto.Changeset{}}

  """
  def delete_video(%Video{} = video) do
    Repo.delete(video)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking video changes.

  ## Examples

      iex> change_video(video)
      %Ecto.Changeset{source: %Video{}}

  """
  def change_video(%Video{} = video) do
    Video.changeset(video, %{})
  end

  defp user_videos(user) do
    assoc(user, :videos)
  end

  def alphabetical(query) do
    from c in query, order_by: c.name
  end

  def names_and_ids(query) do
    from c in query, select: {c.name, c.id}
  end
end
