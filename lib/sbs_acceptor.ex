defmodule Sbs.Acceptor do

  @config Application.get_env(:sbs, :ranch)

  def start_link do
    {:ok, _} = :ranch.start_listener(
      @config[:listener_name],
      @config[:acceptors],
      @config[:transport_type],
      @config[:transport_options],
      Sbs.Worker,
      []
    )
  end
end
