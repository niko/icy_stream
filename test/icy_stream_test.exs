defmodule IcyStreamTest do
  use ExUnit.Case
  doctest IcyStream

  test "smoke" do
       assert Regex.match? ~r/.* - .*/, "Foo Fighters - Learn To Fly"
  end
  test "simple request" do
    task = Task.async fn ->
       IcyStream.fetch "http://eins.stream.laut.fm/eins", %{
         with_headers: fn headers -> IO.inspect(headers) end,
         with_data:    fn _ -> :do_nothing end,
         with_meta:    fn meta ->
           if meta != "" do
             IO.inspect("meta: #{meta}")
             assert Regex.match? ~r/.* - .*/, meta
             exit(:normal)
           end
         end
      }
    end
    ref  = Process.monitor(task.pid)
    assert_receive {:DOWN, ^ref, :process, _, exit_status}, 3000
  end
end
