defmodule Podcatcher.Updater do
  use Supervisor

  alias Podcatcher.Podcasts
  alias Podcatcher.Updater.Worker

  @batch_size 10
  @worker_timeout 1_000_000
  @await_timeout  1_000_000

  def start_link do
    # import Supervisor.Spec, warn: false

    children = [
      :poolboy.child_spec(:worker, poolboy_config(), [])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  def init(_) do
    :ok
  end

  def run do
    Podcasts.list_podcasts
    |> Enum.chunk(@batch_size)
    |> Enum.each(&run_batch/1)
  end

  def run(:no_build_date) do
    Podcasts.list_podcasts
    |> Enum.chunk(@batch_size)
    |> Enum.each(&(run_batch(&1, true)))
  end

  def run_batch(podcasts, no_build_date \\ false) do

    filtered_podcasts = case no_build_date do
      true -> Enum.filter(podcasts, &(is_nil(&1.last_build_date)))
      false -> podcasts
    end

    filtered_podcasts
    |> Enum.map(&Task.async(__MODULE__, :do_fetch, [&1]))
    |> Enum.map(&Task.await(&1, @await_timeout))

  end

  def do_fetch(podcast)  do
    IO.puts podcast.title
    :poolboy.transaction :worker, fn(worker_pid) ->
      Worker.fetch(worker_pid, podcast, @worker_timeout)
    end, @worker_timeout
  end

  defp poolboy_config do
    [{:name, {:local, :worker}},
      {:worker_module, Worker},
      {:size, @batch_size},
      {:max_overflow, 0}]
  end

end
