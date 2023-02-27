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

class HizhiMainWindow : MainWindow {
  this() {
    super("hizhi");
    setSizeRequest(640, 480);
    addOnDestroy((Widget _) { object.destroy(this); });
  }

  ~this() {
    logInfo("Bye.");
    Main.quit();
  }
}

class AudioDrawingArea : DrawingArea {
 public:
  this(float[] buf) {
    _audioBuf = buf;
    addOnDraw(&drawAudio);
  }

 private:
  bool drawAudio(Scoped!Context context, Widget widget) {
    float maxval = maxElement(_audioBuf);
    logInfo("max val: ", maxval);
    context.setLineWidth(1);
    context.setLineCap(CairoLineCap.ROUND); // options are: BUTT, ROUND, SQUARE
    context.setLineJoin(CairoLineJoin.ROUND); // options are: MITER, ROUND, BEVEL
    context.moveTo(0, 240);
    foreach (i, f; _audioBuf[0 .. $ / 2]) {
      if (i % 10 != 0) continue;
      context.lineTo(640 - cast(int) i / 10, f / maxval * 240 + 240);
    }
    context.stroke();
    return true;
  }

  float[] _audioBuf;
}

float[] loadWav(string path) {
  AudioStream input;
  input.openFromFile(path);
  logInfo("sample rate: ", input.getSamplerate);
  logInfo("channels: ", input.getNumChannels);

  float[] buf;
  buf.length = input.getLengthInFrames * input.getNumChannels;
  int length = input.readSamplesFloat(buf);
  logInfo("length: ", length);
  return buf;
}

void main(string[] args) {
  Main.init(args);

  auto draw = new AudioDrawingArea(loadWav("testdata/scream.wav"));
  auto drawBox = new Box(Orientation.VERTICAL, /*padding=*/10);
  drawBox.packStart(draw, /*expand=*/true, /*fill=*/true, /*padding=*/0);

  MainWindow window = new HizhiMainWindow;
  window.add(drawBox);
  window.showAll();
  Main.run();
}
