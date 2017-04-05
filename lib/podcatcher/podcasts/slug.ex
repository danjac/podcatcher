defmodule Podcatcher.Podcasts.Slug do
  use EctoAutoslugField.Slug, from: :title, to: :slug
end


