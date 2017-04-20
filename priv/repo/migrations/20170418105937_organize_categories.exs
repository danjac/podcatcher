defmodule Podcatcher.Repo.Migrations.OrganizeCategories do
  use Ecto.Migration

  alias Podcatcher.Repo
  alias Podcatcher.Categories.Category

  @parent_categories [
    "Arts",
    "Business",
    "Comedy",
    "Education",
    "Games & Hobbies",
    "Government & Organizations",
    "Health",
    "Music",
    "News & Politics",
    "Religion & Spirituality",
    "Science & Medicine",
    "Society & Culture",
    "Sports & Recreation",
    "TV & Film",
    "Technology",

  ]

  @sub_categories [

    {"Design", "Arts"},
    {"Fashion & Beauty", "Arts"},
    {"Food", "Arts"},
    {"Literature", "Arts"},
    {"Performing Arts", "Arts"},
    {"Visual Arts", "Arts"},

    {"Business News", "Business"},
    {"Careers", "Business"},
    {"Investing", "Business"},
    {"Management & Marketing", "Business"},
    {"Shopping", "Business"},

    {"Higher Education", "Education"},
    {"K-12", "Education"},
    {"Language Courses", "Education"},
    {"Training", "Education"},

    {"Automotive", "Games & Hobbies"},
    {"Aviation", "Games & Hobbies"},
    {"Hobbies", "Games & Hobbies"},
    {"Other Games", "Games & Hobbies"},
    {"Video Games", "Games & Hobbies"},

    {"National", "Government & Organizations"},
    {"Non-Profit", "Government & Organizations"},

    {"Alternative Health", "Health"},
    {"Fitness & Nutrition", "Health"},
    {"Self-Help", "Health"},
    {"Sexuality", "Health"},
    {"Kids & Family", "Health"},

    {"Other", "Religion & Spirituality"},
    {"Spirituality", "Religion & Spirituality"},

    {"Medicine", "Science & Medicine"},
    {"Natural Sciences", "Science & Medicine"},
    {"Social Sciences", "Science & Medicine"},

    {"History", "Society & Culture"},
    {"Personal Journals", "Society & Culture"},
    {"Philosophy", "Society & Culture"},
    {"Places & Travel", "Society & Culture"},

    {"Amateur", "Sports & Recreation"},
    {"College & High School", "Sports & Recreation"},
    {"Outdoor", "Sports & Recreation"},
    {"Professional", "Sports & Recreation"},

    {"Gadgets", "Technology"},
    {"Podcasting", "Technology"},
    {"Software How-To", "Technology"},

  ]

  def change do
    Category |> Repo.delete_all

    parent_categories = Enum.map(@parent_categories, fn(name) ->
      %{
        name: name,
        inserted_at: DateTime.utc_now,
        updated_at: DateTime.utc_now,
      }
    end)

    Repo.insert_all(Category, parent_categories)

    sub_categories = Enum.map(@sub_categories, fn({name, parent}) ->
      parent_category = Category |> Repo.get_by!(name: parent)
      %{
        name: name,
        parent_id: parent_category.id,
        inserted_at: DateTime.utc_now,
        updated_at: DateTime.utc_now,
      }
    end)

    Repo.insert_all(Category, sub_categories)

  end
end
