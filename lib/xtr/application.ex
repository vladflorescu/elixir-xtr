defmodule Xtr.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Xtr.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> Xtr.accept(4040) end}, restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: Xtr.Supervisor]
    Supervisor.start_link(children, opts)
  end
end