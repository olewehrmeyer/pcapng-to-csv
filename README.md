# PCAPNG to CSV

Want to do some fancy machine learning or whatever kind of data processing on captured packages? And do you need or want the data in CSV format for this? **Look no further!**

## Usage

You need to have the `tshark` binary installed an on the path. This usually comes with your Wireshark installation.

You need a PCAPNG file (or actually anything that tshark can read).

You can then specify a CSV file with exactly one line, containing a comma-separated list of all the fields you want extracted in the CSV. The availiable fields and their names can be found by running `tshark -G fields`. If e.g. you would be interested in some HTTP info, you could use

```csv
_ws.col.Time,ip.src,ip.dst,tcp.srcport,tcp.dstport,http.request.method,http.request.uri
```

Now, run the tool: `./convert.sh -f <format-file.csv> -i <input.pcapng> -o <output.csv> [-t <tshark time format>] [-y <display filter>]`

You can provide a Wireshark display filter to filter the packets that end up in the CSV. If you use the `_ws.col.Time` column containing the packet timestamp, the `-t` parameter can be used to control the format. It defaults to `e` for a linux timestamp. Check `man tshark` for all other options.