defmodule Podcatcher.Web.EpisodesView do
  use Podcatcher.Web, :view

  alias Podcatcher.Episodes.Episode

  @mime_types [
    {".aa", "audio/audible"},
    {".aac", "audio/aac"},
    {".aax", "audio/vnd.audible.aax"},
    {".ac3", "audio/ac3"},
    {".adt", "audio/vnd.dlna.adts"},
    {".adts", "audio/aac"},
    {".aif", "audio/x-aiff"},
    {".aifc", "audio/aiff"},
    {".aiff", "audio/aiff"},
    {".au", "audio/basic"},
    {".caf", "audio/x-caf"},
    {".m3u", "audio/x-mpegurl"},
    {".m3u8", "audio/x-mpegurl"},
    {".m4a", "audio/m4a"},
    {".m4b", "audio/m4b"},
    {".m4p", "audio/m4p"},
    {".m4r", "audio/x-m4r"},
    {".mid", "audio/mid"},
    {".midi", "audio/mid"},
    {".mp4", "audio/mp4"},
    {".mp4a", "audio/mp4"},
    {".mp1", "audio/mpeg"},
    {".mp2", "audio/mpeg"},
    {".mp3", "audio/mpeg"},
    {".mpg", "audio/mpeg"},
    {".mpeg", "audio/mpeg"},
    {".oga", "audio/ogg"},
    {".ogg", "audio/ogg"},
    {".ra", "audio/x-pn-realaudio"},
    {".ram", "audio/x-pn-realaudio"},
    {".rmi", "audio/mid"},
    {".rpm", "audio/x-pn-realaudio-plugin"},
    {".sd2", "audio/x-sd2"},
    {".smd", "audio/x-smd"},
    {".smx", "audio/x-smd"},
    {".smz", "audio/x-smd"},
    {".snd", "audio/basic"},
    {".wav", "audio/wav"},
    {".wave", "audio/wav"},
    {".wax", "audio/x-ms-wax"},
    {".webm", "audio/webm"},
    {".wma", "audio/x-ms-wma"},
  ] |> Map.new

  def audio_mimetype(url) when is_nil(url), do: ""

  def audio_mimetype(url) do
    ext = URI.parse(url).path |> Path.extname
    Map.get @mime_types, ext, ""
  end

  def safe_protocol(url) when is_nil(url), do: ""

  def safe_protocol(url) do
    Regex.replace(~r/https?\:\/\//, url, "//")
  end

  def keywords(%Episode{keywords: nil}), do: []

  def keywords(episode) do
    episode.keywords
    |> String.trim
    |> String.split(",")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.downcase/1)
  end

end
