defmodule Podcatcher.Parser.Worker do
  use GenServer
  require Logger

  alias Podcatcher.Podcasts

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def fetch(pid, podcast, timeout) do

    try do
      result = Podcasts.update_podcast_from_rss_feed(podcast)
      if result == :ok do
        GenServer.call(pid, {:fetch, podcast.id}, timeout)
      end
    catch
      :exit, _ -> Logger.error "Some exiting"
    end

  end

  def handle_call({:fetch, result}, _from, state) do
    {:reply, result, state}
  end

end
