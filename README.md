# 篳 hizhi: D audio workstation app.

## Requirements

Ubuntu 22.04 LTS

```shell
$ sudo apt install libgtk-3-dev libavcodec-dev libavformat-dev libavdevice-dev
```

## TODO

- [x] Draw a waveform.
- [ ] Load a waveform file.
- [ ] Play a waveform.
- [ ] Edit waveforms e.g. reverse, gain.
- [ ] Save a waveform file.
- [ ] Support multiple tracks, i.e. mixing.
- [ ] Support clips, e.g. time shifting, copy-pasting.
- [ ] Play waveform with VST effects.
- [ ] Draw midi notes.
- [ ] Play midi notes with VST instruments.
- [ ] Windows support.


## Dev tips

- Use mold linker to build an app faster. gtk-3 is too slow with other linkers.
