defmodule Mix.Tasks.Podcatcher.Update do
  use Mix.Task

  @shortdoc "Update all the podcasts"
  def run(_) do
    Mix.Task.run "app.start"
    Podcatcher.Updater.run()
  end

end
