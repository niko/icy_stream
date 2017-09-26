
stations = ~w(1000oldies 0-24_80er_pop_rock 1000schlager 100prozentschlager 1000italohits 1000goldschlager 0-24_oldies_pop_rock 1000smoothhits simliveradio 1000countryhits eifellounge 1_slowradio kinderlieder-123 hits_80s 0-24_schlager_volksmusik germanyrock -1-st-80s-fire-fm volksmusikradio kinderlieder oldoldies 0-24_charts_pop_rock 1000discohits 1-oldies dein-radio-berlin 1000rockhits darkclubradio katzenpuff discofox oktoberfest kinderradio chillharmonie bluesclub ibiza-unique jahfari schlager 1000melodien velvetlounge bluesrockcafe rocknblues hiphop-forever 101fm eurosmoothjazz best_of_80s 1000volksmusikhits simulator1 classicrock jazzloft 1000hits 0-24_90er_pop_rock nummer_1_oldies mittelalter-net celtic-rock houseschuh alpenradio 90er 100080er alles-volksmusik best-of-klassik ondalatina all-time-best chillout-archiv 80er-revival acidjazz 1-radio-latino 80er loungeradio goa-base eurodance magic-top100 schlager-radio soulfood randyfm italo-disco abstrait 1000christmashits der-barde life4enjoy goanight 54-funk-soul-dance radiorock rockthefolk club85 housebomb-fn popschlager nasty radio_relax progman schlagerradio just70s skafari 100prozentvolksmusik dark-bites africa_goes_angeln 7mix rock-the-blues groovefm schlagerradio-germany tangoparabailar minimalcalling deutschrap ultradarkradio veedelsradiozwei oldiemania berlinrap pineapplejuice zipfelalm 49dance karneval deepahouse celtic-sounds 0-24_2000er_pop_rock thejazzofwiesbaden goa-channel-one hitbox oldiewelle-roding deutschrap-deluxe hoerspiel just80s_maximal antenne-oldies just80s chronisch_elektronisch radio-holiday 030-berlinfm metal-hammer jazzwelt deep-pressure-music treffpunkt-evergreen club93 bluesstation4you plattenkeller just90s chart-tipps lounge)

# stations = ~w(1000oldies 0-24_80er_pop_rock 1000schlager 100prozentschlager 1000italohits 1000goldschlager 0-24_oldies_pop_rock 1000smoothhits simliveradio 1000countryhits eifellounge)

:lhttpc_manager.set_max_pool_size :lhttpc_manager, 5000

tasks = Enum.map(stations, fn station ->
  Process.sleep 300
  IO.puts "starting #{station}…"
  Task.async(fn ->
             IcyStream.fetch "http://1.stream.laut.fm/#{station}",
               %{
                  with_meta: fn meta -> meta != "" && IO.inspect("#{station}: #{meta}") end,
                  with_data: fn _ -> end,
                  with_headers: fn _ -> end
                }

    IO.puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #{station} CRASHED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  end)
end)

# Task.yield_many(tasks, 1000 * 60 * 60 * 24)
Process.sleep 1000 * 60 * 5 # five minutes

IO.puts "Ende Gelände"

