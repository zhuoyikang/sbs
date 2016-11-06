require Logger

defmodule Sbs.Worker do

  use GenServer
  # use Types

  @behaviour :ranch_protocol
  @timeout Application.get_env(:server, :protocol, 5000)

  def start_link(ref, socket, transport, opts \\ []) do
    :proc_lib.start_link(__MODULE__, :init, [ref, socket, transport, opts])
  end

  @doc """
  这里是最重要的部分, 不能直接使用`GenServer.start_link/4`,
  要绕过`GenServer`的默认行为. 否则会进入死循环.
  """
  def init(ref, socket, transport, opts \\ []) do
    # add_socket(socket)
    :erlang.process_flag(:trap_exit, true)
    Logger.debug "#{__MODULE__}:init/4 called. options: #{inspect opts}"
    # 通知父进程
    :ok = :proc_lib.init_ack({:ok, self()})
    # 移交套接字控制权
    :ok = :ranch.accept_ack(ref)
    # 主动接收一次,然后切换到被动
    :ok = transport.setopts(socket, [{:active, :once}, {:packet, 2}])
    # 初始化进程状态
    state = %{
      socket: socket,
      transport: transport
    }
    # 进入循环
    :ets.insert(:clients, {self(), socket})
    :gen_server.enter_loop(__MODULE__, [], state)
  end

  # 转发消息
  def handle_info({:data, data}, %{
                    socket: socket,
                    transport: transport} = state) do

    transport.send(socket, data)
    {:noreply, state}
  end

  def handle_info({:tcp, _socket, data}, %{
                    socket: socket,
                    transport: transport
                  } = state) do
    :ok = transport.setopts(socket, [{:active, :once}])

    list = :ets.tab2list(:clients)

    for {pid, _} <- list, pid != self() ,do: send pid, {:data, data}

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    {:stop, :normal, state}
  end

  @doc """
  Invoked when the server is about to exit. It should do any cleanup required.
  """
  def terminate(reason, _state) do
    Logger.warn "process exit with reason: #{inspect reason}"
    :ets.delete(:clients, self())
    :ok
  end

end
