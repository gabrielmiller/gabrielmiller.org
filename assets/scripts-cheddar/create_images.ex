# reference map shape
# %{
#   label: "",
#   date: "",
#   filename: "",
#   video: false,
# }

paths = [
  "IMAGE: IMG_2020_xyz.jpg",
  "IMAGE: PXL_2020_xyz.jpg",
  "VIDEO: PXL_2020_xyz.mp4",
  "IMAGE: MVIMG_2020_xyz.jpg",
  "GIF: 2010-01-01.gif",
  # ... and so on
]

paths |> Enum.reduce(%{}, fn path, acc ->
  file_and_extension =
    path
    |> String.split(" ")
    |> Enum.at(1)

  filename =
    file_and_extension
    |> String.split(".")
    |> Enum.at(0)

  entry = Map.get(acc, filename, %{ label: "", date: "", filename: nil, video: false })

  cond do
    String.starts_with?(path, "IMAGE: ") ->
      entry = entry
      |> Map.put(:filename, file_and_extension)

      Map.put(acc, filename, entry)
    String.starts_with?(path, "VIDEO: ") ->
      entry = entry
      |> Map.put(:video, true)

      Map.put(acc, filename, entry)
    String.starts_with?(path, "GIF: ") ->
      entry = entry
      |> Map.put(:filename, file_and_extension)

      Map.put(acc, filename, entry)
    true -> raise "not implemented"
  end
end)
|> Map.values()
|> Enum.sort_by(& &1.filename)
|> Enum.each(& IO.inspect(&1))
