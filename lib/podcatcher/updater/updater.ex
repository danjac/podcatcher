defmodule Podcatcher.Parser do
  use Supervisor

  alias Podcatcher.Podcasts
  alias Podcatcher.Updater.Worker

  @worker_timeout 100_000
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
    |> Enum.chunk(10)
    |> Enum.map(&run_batch/1)
    |> List.flatten
  end


  defp run_batch(podcasts) do

    podcasts
    |> Enum.map(&Task.async(__MODULE__, :do_fetch, [&1]))
    |> Enum.map(&Task.await(&1, @await_timeout))

  end

  def do_fetch(podcast)  do
    :poolboy.transaction :worker, fn(worker_pid) ->
      Worker.fetch(worker_pid, podcast, @worker_timeout)
    end, @worker_timeout
  end

  defp poolboy_config do
    [{:name, {:local, :worker}},
      {:worker_module, Worker},
      {:size, 5},
      {:max_overflow, 2}]
  end

end
