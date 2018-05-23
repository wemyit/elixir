defmodule Rumbl.App.Annotation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rumbl.App.Annotation


  schema "annotations" do
    field :at, :integer
    field :body, :string
    belongs_to :user, Rumbl.Crowd.User
    belongs_to :video, Rumbl.App.Video

    timestamps()
  end

  @doc false
  def changeset(%Annotation{} = annotation, attrs) do
    annotation
    |> cast(attrs, [:body, :at])
    |> validate_required([:body, :at])
  end
end
