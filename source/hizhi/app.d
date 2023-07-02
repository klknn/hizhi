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
  this(AudioStream* audio) {
    assert(audio.canSeek);
    _audio = audio;
    addOnDraw(&drawAudio);
  }

private:
  bool drawAudio(Scoped!Context context, Widget widget) {
    _audio.seekPosition(0);
    context.setLineWidth(1);
    context.setLineCap(CairoLineCap.ROUND); // options are: BUTT, ROUND, SQUARE
    context.setLineJoin(CairoLineJoin.ROUND); // options are: MITER, ROUND, BEVEL
    context.moveTo(0, 240);

    float[10] buf;
    for (int i = 0; i < _audio.getLengthInFrames; i += _audio.readSamplesFloat(buf)) {
      context.lineTo(640 - i / cast(int) buf.length, buf[0] * 240 + 240);
    }
    context.moveTo(640, 240);
    context.stroke();
    return true;
  }

  AudioStream* _audio;
}

void main(string[] args) {
  Main.init(args);

  auto audio = new AudioStream;
  audio.openFromFile("testdata/scream.wav");
  auto draw = new AudioDrawingArea(audio);
  auto drawBox = new Box(Orientation.VERTICAL, /*padding=*/ 10);
  drawBox.packStart(draw, /*expand=*/ true, /*fill=*/ true, /*padding=*/ 0);

  MainWindow window = new HizhiMainWindow;
  window.add(drawBox);
  window.showAll();
  Main.run();
}
