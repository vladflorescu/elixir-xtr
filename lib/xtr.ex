require Logger

defmodule Xtr do
  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client_socket} = :gen_tcp.accept(socket)

    Logger.info "Client connected"
    {:ok, pid} = Task.Supervisor.start_child(Xtr.TaskSupervisor, fn ->
      serve(client_socket, Xtr.CLI.init)
    end)

    :ok = :gen_tcp.controlling_process(client_socket, pid)
    loop_acceptor(socket)
  end

  defp serve(client_socket, cli) do
    desc = Xtr.CLI.get_current_description(cli)
    :gen_tcp.send(client_socket, desc <> "\r\n")
    {:ok, str} = :gen_tcp.recv(client_socket, 0)

    normalize = fn str -> String.replace(str, ~r/(\r\n|\r|\n)$/, "") end
    serve(client_socket, Xtr.CLI.invoke(cli, normalize.(str)))
  end

  defp read_line(client_socket) do
    {:ok, str} = :gen_tcp.recv(client_socket, 0)
    Xtr.Command.exec(str |> String.replace(~r/(\r\n|\r|\n)$/, ""))
  end

  defp write_line(line, client_socket) do
    :gen_tcp.send(client_socket, line <> "\r\n")
  end
end
