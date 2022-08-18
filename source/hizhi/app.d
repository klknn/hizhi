module hizhi.app;

/* hizhi gtk-3 app.

Notes

Useful GTK3 demo apps
- Cairo for arbitary drawing
- Icon View > Editing and Drag-and-Drop for clip drawing
- Color Chooser for selecting clip colors

Useful GTK4 demo apps
- Paintable for SVG and resizable images

*/

import audioformats;
import cairo.Context;
import gtk.FileChooserDialog;
import gtk.MainWindow;
import gtk.Main;
import gtk.Box;
import gtk.Widget;
import gtk.DrawingArea;
import hizhi.logging;
import std.algorithm;

int main(string[] args) {
  AudioStream input;
  input.openFromFile("testdata/scream.wav");
  logInfo("sample rate: ", input.getSamplerate);
  logInfo("channels: ", input.getNumChannels);

  float[] buf;
  buf.length = input.getLengthInFrames * input.getNumChannels;
  int length = input.readSamplesFloat(buf);
  float maxval = maxElement(buf);

  Main.init(args);

  auto draw = new DrawingArea;
  draw.addOnDraw((Scoped!Context context, Widget widget) {
      context.setLineWidth(1);
      context.setLineCap(CairoLineCap.ROUND); // options are: BUTT, ROUND, SQUARE
      context.setLineJoin(CairoLineJoin.ROUND); // options are: MITER, ROUND, BEVEL
      context.moveTo(0, 240);
      foreach (i; 0 .. length) {
        if (i % 10 != 0) continue;
        context.lineTo(640 - i / 10, buf[i] / maxval * 240 + 240);
      }
      context.stroke();
      return true;
  });
  auto drawBox = new Box(Orientation.VERTICAL, /*padding=*/10);
  drawBox.packStart(draw, /*expand=*/true, /*fill=*/true, /*padding=*/0);

  MainWindow window = new MainWindow("main");
  window.setSizeRequest(640, 480);
  window.addOnDestroy((w) { Main.quit(); });
  window.add(drawBox);
  window.showAll();

  Main.run();

  version (ffmpeg) {
    import ffmpeg.libavcodec.avcodec;
    import ffmpeg.libavformat.avformat;
    import ffmpeg.libavformat.avio;
    import ffmpeg.libavutil.avutil;
    import ffmpeg.libavutil.frame;
    import ffmpeg.libavutil.mathematics;


    // Initialize libavcodec, and register all codecs and formats.
    av_register_all();

    // Load wav.
    AVFormatContext* format;
    if (avformat_open_input(&format, "scream.wav", null, null)) {
      logFatal("Cannot load wav.");
      return 1;
    }
    if (avformat_find_stream_info(format, null) < 0) {
      logFatal("Cannot find stream.");
      return 1;
    }

    // writeln("AVFormatContext {");
    // foreach (i, t; format.tupleof) {
    //   writeln("  ", FieldNameTuple!AVFormatContext[i], ": ", t);
    // }
    // writeln("}");

    AVStream* stream;
    foreach (i; 0 .. format.nb_streams) {
      stream = format.streams[i];
      if (stream.codecpar.codec_type == AVMediaType.AVMEDIA_TYPE_AUDIO) {
        logInfo("Found stream.");
        break;
      }
    }

    logInfo("Finish main().");
  }

  return 0;
}
