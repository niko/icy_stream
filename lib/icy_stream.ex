defmodule IcyStream do
  @moduledoc """
  A simple lib to fetch and parse Icy streams.

  Given three callbacks (for headers, body and the icy meta data) it will do an http request and call the respective callbacks with headers, chunks of the body and the metadata.
  Utilizes lhttpc under the hood.
  """

  @doc ~S"""
  IcyStream.fetch/2

  ## Examples

      iex(1)> IcyStream.fetch "http://eins.stream.laut.fm/eins", %{
      ...(1)> with_meta:    fn meta -> meta != "" && IO.inspect("meta: #{meta}") && exit("done") end,
      ...(1)> with_headers: fn headers -> IO.inspect(headers) end,
      ...(1)> with_data:    fn _ -> :do_nothing end
      ...(1)> }
      [{'content-type', 'audio/mpeg'}, {'connection', 'close'}, {'icy-name', 'eins'},
       {'pragma', 'no-cache'}, {'icy-metaint', '1024'},
       {'expires', 'Mon, 26 Jul 1997 05:00:00 GMT'},
       {'icy-genre', 'Alternative,Indie,Electropop'},
       {'server', 'AIS Streaming Server 7.7.9'}, {'cache-control', 'no-cache'},
       {'instance-id', '461de947f0894534cff9573db76a1c99'},
       {'icy-url', 'laut.fm/eins'}, {'access-control-allow-origin', '*'},
       {'icy-description', 'Brandneue Tracks aus Indie, Pop und Electro. Discover your new favourite band & turn it up!'},
       {'icy-pub', '1'}, {'icy-br', '128'}, {'x-radioname', 'laut.fm'}
      ]
      "meta: Shock Machine - Unlimited Love"
      ** (exit) "done
          (stdlib) erl_eval.erl:668: :erl_eval.do_apply/6
          (icy_stream) lib/icy_stream.ex:85: IcyStream.ingest_body/4

      """

  # the default callback functions:
  defp with_data(data) do
    IO.inspect [:data, byte_size(data)]
  end
  defp with_meta(meta) do
    meta != "" && IO.inspect [:meta, meta]
  end
  defp with_headers(headers) do
    IO.inspect [:headers, headers]
  end

  def fetch(path, callbacks \\ %{}) do
    default_callbacks = %{with_data: &with_data/1, with_meta: &with_meta/1, with_headers: &with_headers/1}
    callbacks = Map.merge default_callbacks, callbacks

    case :lhttpc.request(
      to_char_list(path), :get, [{"icy-metadata", "1"},{"user-agent","Elixir Icy Parser"}], "", :infinity,
      [{:partial_download, [{:window_size, 10}, {:part_size, 1000}]}]) do

    # 200 OK:
    {:ok, {{200, _}, response_headers, body}} ->
      callbacks[:with_headers].(response_headers)
      {'icy-metaint', icy_metaint} = List.keyfind(response_headers, 'icy-metaint', 0)
      {icy_metaint, _} = :string.to_integer icy_metaint
      ingest_body(body, icy_metaint, callbacks)

    # other status codes:
    {:ok, {{status_code, _}, response_headers, _body}} ->
      IO.inspect [status_code, response_headers]

    # error:
    {:error, reason} ->
      IO.inspect reason
    end

  end

  # http://www.smackfu.com/stuff/programming/shoutcast.html
  defp ingest_body(body, icy_metaint, callbacks, buffer \\ <<>>) do
    case :lhttpc.get_body_part(body) do
    # case :lhttpc.get_body_part(body, 5000) do
      {:ok, chunk} when is_binary(chunk) ->
        buffer = buffer <> chunk

        if byte_size(buffer) > icy_metaint + 255*8 do # max metadata size is 255 * 16= 4080
          {mp3, rest}            = :erlang.split_binary buffer, icy_metaint
          {icy_metalength, rest} = :erlang.split_binary rest, 1
          {icy_meta, rest}       = :erlang.split_binary rest, :binary.decode_unsigned(icy_metalength) * 16
          icy_meta = icy_meta |> String.split("StreamTitle='") |> List.last |> String.split("';") |> List.first

          callbacks[:with_data].(mp3)
          callbacks[:with_meta].(icy_meta)

          buffer = rest
        end

        ingest_body(body, icy_metaint, callbacks, buffer)

      {:ok, {:http_eob, _}} -> nil

      {:error, err} ->
        IO.puts "ERROR!?!"
        raise err
    end
  end


end

