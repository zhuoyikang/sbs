defmodule Sbs.Admin do
  use GenServer

  @doc """
  Start the User Woker
  """
  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  def init([]) do
    :clients = :ets.new(:clients, [:public, :named_table])
    {:ok, %{}}
  end

  def handle_call(msg, _from, state) do
    {:reply, msg, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

end
