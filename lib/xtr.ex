require Logger

defmodule Xtr do
  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client_socket} = :gen_tcp.accept(socket)

    Logger.info "A client connected"
    {:ok, pid} = Task.Supervisor.start_child(Xtr.TaskSupervisor, fn ->
      serve(client_socket, Xtr.CLI.init)
    end)

    :ok = :gen_tcp.controlling_process(client_socket, pid)
    loop_acceptor (socket)
  end

  defp serve(client_socket, cli, last_feedback \\ nil) do
    :gen_tcp.send(client_socket, compute_client_message(cli, last_feedback))
    {:ok, str} = :gen_tcp.recv(client_socket, 0)

    normalize = fn str -> String.replace(str, ~r/(\r\n|\r|\n)$/, "") end

    case Xtr.CLI.invoke(cli, normalize.(str)) do
      {:exit, _} ->
        :ok = :gen_tcp.shutdown(client_socket, :write)
        Logger.info "A client disconnected"
      {next_cli, msg} ->
        serve(client_socket, next_cli, msg || "")
    end
  end

  defp compute_client_message(cli, last_feedback) do
    desc = Xtr.CLI.get_current_description(cli)
    desc_preffix = if last_feedback == nil, do: "", else: last_feedback <> "\r\n\r\n"
    desc_preffix <> desc <> "\r\n"
  end
end
