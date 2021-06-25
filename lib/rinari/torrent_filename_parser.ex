defmodule Rinari.TorrentFilenameParser do
  @patterns %{
      season: '[\. ]((?:Complete.)?s[0-9]{2}-s[0-9]{2}|s([0-9]{1,2})(?:e[0-9]{2})?|([0-9]{1,2})x[0-9]{2})(?:[\. ]|$)',
      episode: '((?:[ex]|ep)([0-9]{2})(?:[^0-9]|$))',
      year: '([\[\(]?((?:19[0-9]|20[0-9])[0-9])[\]\)]?)',
      resolution: '([0-9]{3,4}p|1280x720)',
      quality: '((?:PPV\.)?[HP]DTV|(?:HD)?CAM|B[DR]Rip|(?:HD-?)?TS|(?:PPV )?WEB-?DL(?: DVDRip)?|HDRip|HDTVRip|DVDRip|DVDRIP|CamRip|W[EB]BRip|BluRay|DvDScr|hdtv|telesync)',
      codec: '(xvid|[hx]\.?26[45])',
      audio: '(MP3|DD2\.?0|DDP2\.?0|DD5\.?1|DDP5\.?1|Dual[\- ]Audio|LiNE|DTS|DTS5\.1|AAC[ \.-]LC|AAC(?:\.?2\.0)?|AC3(?:\.5\.1)?)',
      group: '(- ?([^-]+(?:-={[^-]+-?$)?))$',
      region: 'R[0-9]',
      extended: '(EXTENDED(:?.CUT)?)',
      hardcoded: 'HC',
      proper: 'PROPER',
      repack: 'REPACK',
      container: '(MKV|AVI|MP4)',
      widescreen: 'WS',
      website: '^(\[ ?([^\]]+?) ?\])',
      language: '(rus\.eng|ita\.eng|nordic)',
      subtitles: '(DKsubs)',
      sbs: '(?:Half-)?SBS',
      unrated: 'UNRATED',
      size: '(\d+(?:\.\d+)?(?:GB|MB))',
      "3d": '3D'
    }

  @types %{
    season: :integer,
    episode: :integer,
    year: :integer,
    extended: :boolean,
    hardcoded: :boolean,
    proper: :boolean,
    repack: :boolean,
    widescreen: :boolean,
    unrated: :boolean,
    "3d": :boolean
  }

  @bt_sites ['eztv', 'ettv', 'rarbg', 'rartv', 'ETRG']

  defp strip_surrounding(s, chars) do
    Regex.compile("[#{chars}]*([#{chars}]*)[#{chars}]*")
    |> Regex.replace(s, "")
  end

  defp extract_part(state, name, match, raw, clean) do
    state = if Enum.count(match) > 0 do
      index = :binary.match(state[:torrent][:name], Enum.at(match, 0))

      {start, end_ } = case index do
                         :nomatch -> {String.length(match), state[:end]}
                         {index, _} -> if state[:end] == nil || index < state[:end] do
                           {state[:start], index}
                         else
                           {state[:start], state[:end]}
                         end
                       end

      {group_raw, excess_raw} = if name != :excess do
        g = if name == :group do
          raw
        else
          state[:group_raw]
        end
        e = if raw do
          state[:excess_raw] |> String.replace(raw, '')
        else
          state[:excess_raw]
        end
        {g, e}
      end

      %{state | start: start, end: end_, group_raw: group_raw, excess_raw: excess_raw}
    else
      state
    end

    %{state | parts: Map.put(state[:parts], name, clean)}
  end

  defp extract_late(state, name, clean) do
    case name do
      :group -> extract_part(state, name, [], nil, clean)
      :episode_name ->
        clean = Regex.replace(~r/[\._]/, clean, ' ')
        clean = Regex.replace(~r/_+$/, clean, ' ')
        extract_part(state, name, [], nil, String.trim(clean))
      _ -> state
    end
  end

  def parse(name) do
    state = %{
      parts: %{},
      torrent: %{name: name},
      excess_raw: name,
      group_raw: "",
      start: 0,
      end: nil,
      title_raw: nil
    }

    state = for {key, pattern} <- @patterns do
      pattern = if key not in [:season, :episode, :website] do
        "\b#{pattern}\b"
      else
        pattern
      end

      pattern = if key == :year do
        ".#{pattern}"
      else
        pattern
      end

      clean_name = String.replace(state[:torrent][:name], "_", " ")
      matches = Regex.compile(pattern, "i") |> Regex.scan(clean_name)

      state = if Enum.count(matches) > 0 do
        index = case matches do
                  [_] -> %{raw: 0, clean: 0}
                  [_|_] -> %{raw: 0, clean: 1}
                end

        clean = cond do
          key == :season && index[:clean] == 0 ->
            m = Regex.scan(~r/s([0-9]{2})-s([0-9]{2})/i, clean_name)
            if Enum.count(m) > 0 do
              elem(Integer.parse(m[0][0]), 1)..elem(Integer.parse(m[0][1]), 1)+1
            else
              nil
            end
          @types[key] == :boolean -> true
          true ->
            if @types[key] == :integer do
              matches[index[:clean]] |> Integer.parse |> elem(1)
            else
              matches[index[:clean]]
            end
        end

        key = if key == :group do
          if not (clean =~ Regex.compile(@patterns[:codec], "i") || clean =~ Regex.compile(@patterns[:quality])) do
            if clean =~ ~r/[^ ]+ [^ ]+ .+/ do
                                       :episode_name
                                       else
                                         key
            end
          else
            key
          end
        end

        state = if key == :episode do
          put_in(state, [:torrent, :map], String.replace(matches[index[:raw]], "{episode}", clean))
        else
          state
        end

        extract_part(state, key, matches, matches[index[:raw]], clean)
      end

      state
    end

    raw = state[:torrent][:name]

    raw = if state[:end] do
      String.slice(raw, state[:start]..state[:end]) |> String.split("(") |> Enum.at(0)
    else
      raw
    end

    clean = Regex.replace(raw, ~r/^ -/, "")
    if String.contains?(clean, " ") && !String.contains?(clean, ".") do
      String.replace(clean, ".", " ")
    else
      clean
    end
    clean = clean |> String.replace("_", " ")
    clean = Regex.replace(~r/([\[\(_]|- )$/, clean, "")
    |> String.trim
    |> strip_surrounding(" -_")

    state = extract_part(state, :title, [], raw, clean)

    clean = Regex.replace(~r/(^[-\. ()]+)|([-\. ]+$)/, '', state[:excess_raw])
    clean = Regex.replace(~r/[\(\)\/]/, '', clean)
    clean = String.split(clean, ~r/(.*)\.\.+| +(.*)/)
    |> Enum.filter(fn a -> a != "-" end)
    |> Enum.map(fn a -> String.trim(a, "-") end)

    state = if Enum.count(clean) > 0 do
      group_pattern = "#{Enum.at(clean, -1)}#{state[:group_raw]}"
      state = case :binary.match(state[:torrent][:name], group_pattern) do
        {pos, _} ->
          if pos == String.length(state[:torrent][:name]) - String.length(group_pattern) do
                                                            extract_late(state, :group, String.slice(clean, 0..-2) <> state[:group_raw])
                                                            else
                                                              state
          end
          _ -> state
      end

      if state[:torrent][:map] do
        episode_name_pattern = "{episode}" <> Regex.replace(~r/_+$/, Enum.at(clean, 0), "")
        if String.contains?(state[:torrent][:map], episode_name_pattern) do
          extract_late(state, :episode_name, String.slice(clean, 0..-2))
        else
          state
        end
      else
        state
      end
    end

    state = case state[:parts] do
      %{group: group, container: container} ->
        if String.downcase(group) |> String.ends_with?("." <> String.downcase(container)) do
          put_in(state, [:parts, :group], String.slice(group, 0..-String.length(container)-2))
        else
          state
        end
      _ -> state
    end

    state = case state[:parts] do
      %{group: group} ->
        sites = Enum.join(@bt_sites, "|")
        group = Regex.compile("\[(#{sites})\]$", "i") |> Regex.replace(group, "")
        put_in(state, [:parts, :group], group)
      _ -> state
    end

    if not Enum.empty?(clean) do
      clean = if Enum.count(clean) == 1 do
        Enum.at(clean, 0)
      else
        clean
      end
      extract_part(state, :excess, [], state[:excess_raw], clean)
    else
      state
    end
  end
end
