defmodule SbsTest do
  use ExUnit.Case
  doctest Sbs

  test "the truth" do
    assert 1 + 1 == 2
    {:ok, sock1} = :gen_tcp.connect('127.0.0.1', 4001, [:binary, {:packet, 2}, {:active, true}])
    {:ok, sock2} = :gen_tcp.connect('127.0.0.1', 4001, [:binary, {:packet, 2}, {:active, true}])
    {:ok, sock3} = :gen_tcp.connect('127.0.0.1', 4001, [:binary, {:packet, 2}, {:active, true}])
    {:ok, sock4} = :gen_tcp.connect('127.0.0.1', 4001, [:binary, {:packet, 2}, {:active, true}])


    :timer.sleep(1000)
    :gen_tcp.send(sock1, "abcdefg")

    assert (receive do {:tcp, sock2, data} -> data end)  == "abcdefg"
    assert (receive do {:tcp, sock3, data} -> data end)  == "abcdefg"
    assert (receive do {:tcp, sock4, data} -> data end)  == "abcdefg"

  end
end
 
