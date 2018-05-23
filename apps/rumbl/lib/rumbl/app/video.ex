defmodule Rumbl.App.Video do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rumbl.App.Video


  @primary_key {:id, Rumbl.Permalink, autogenerate: true}
  schema "videos" do
    field :description, :string
    field :title, :string
    field :url, :string
    field :slug, :string
    belongs_to :user, Rumbl.Crowd.User
    belongs_to :category, Rumbl.App.Category
    has_many :annotations, Rumbl.App.Annotation

    timestamps()
  end

  @required_fields ~w(url title description)a
  @optional_fields ~w(category_id)a
  
  @doc false
  def changeset(%Video{} = video, attrs \\ %{}) do
    video
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> slugify_title()
    |> assoc_constraint(:category)
  end

  defp slugify_title(changeset) do
    if title = get_change(changeset, :title) do
      put_change(changeset, :slug, slugify(title))
    else
      changeset
    end
  end
  
  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
  end

  defimpl Phoenix.Param do
    def to_param(%{slug: slug, id: id}) do
      "#{id}-#{slug}"
    end
  end
end
