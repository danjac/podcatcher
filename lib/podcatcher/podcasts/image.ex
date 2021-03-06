defmodule Podcatcher.Podcasts.Image do
  use Arc.Definition
  use Arc.Ecto.Definition

  alias Podcatcher.Podcasts.Podcast

  # To add a thumbnail version:
  @versions [:large, :small]

  # Whitelist file extensions:
  # def validate({file, _}) do
  #   ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  # end

  # Define a thumbnail transformation:
  def transform(:large, _) do
    {:convert, "-strip -thumbnail 300x300^ -gravity center -extent 300x300 -format png", :png}
  end

  def transform(:small, _) do
    {:convert, "-strip -thumbnail 100x100^ -gravity center -extent 100x100 -format png", :png}
  end

  # Override the persisted filenames:
  def filename(version, {_file, _scope}) do
    version
  end

  def storage_dir(_version, {_file, %Podcast{slug: slug, website: website}}) when slug == "" do
    host = URI.parse(website).host |> String.downcase
    |> URI.parse

    "uploads/podcasts/#{host}"
  end

  def storage_dir(_version, {_file, %Podcast{slug: slug}}) do
    "uploads/podcasts/#{slug}"
  end

  # Override the storage directory:
  # def storage_dir(version, {file, scope}) do
  #   "uploads/user/avatars/#{scope.id}"
  # end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: Plug.MIME.path(file.file_name)]
  # end
end
