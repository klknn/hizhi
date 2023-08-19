module hizhi.logging;

import std.path;
import std.stdio;
import std.datetime;
import std.process;

enum LogSeverity : char {
  info = 'I',
  warning = 'W',
  error = 'E',
  fatal = 'F',
}

void logPrefix(LogSeverity severity, string file, int line) {
  SysTime curr = Clock.currTime();
  DateTime date = cast(DateTime) curr;

  // Based on abseil format.
  // https://github.com/abseil/abseil-py/blob/f0679ed8e79d1352f23b80965981b704bd48e1a4/absl/logging/__init__.py#L741
  enum fmt = "%c%02d%02d %02d:%02d:%02d.%06d %5d %s:%d] ";

  std.stdio.stderr.writef!fmt(
      severity,
      cast(int) date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
      convert!("hnsecs", "usecs")(curr.stdTime % 1_000_000),
      cast(int) thisThreadID(),
      baseName(file),
      line);
}

void logInfo(string file = __FILE__, int line = __LINE__, Args...)(Args args) {
  logPrefix(LogSeverity.info, file, line);
  std.stdio.stderr.writeln(args);
}

void logWarning(string file = __FILE__, int line = __LINE__, Args...)(Args args) {
  logPrefix(LogSeverity.warning, file, line);
  std.stdio.stderr.writeln(args);
}

void logError(string file = __FILE__, int line = __LINE__, Args...)(Args args) {
  logPrefix(LogSeverity.error, file, line);
  std.stdio.stderr.writeln(args);
}

void logFatal(string file = __FILE__, int line = __LINE__, Args...)(Args args) {
  logPrefix(LogSeverity.fatal, file, line);
  std.stdio.stderr.writeln(args);
  assert(false);
}
