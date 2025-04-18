defmodule Genetic.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Utilities.Statistics, []}
    ]

    opts = [strategy: :one_for_one, name: Genetic.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
