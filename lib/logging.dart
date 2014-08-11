library ormicida.logging;

import 'dart:typed_data';
import 'package:ormicida/bytes/buffer.dart';

/// The singleton logger for the current isolate.
final Logger logger = new Logger._();

class Level {
  static const ALL      =   0;
  static const DEBUG    =  10;
  static const INFO     =  20;
  static const CONFIG   =  30;
  static const OK       =  40;
  static const WARNING  =  50;
  static const ERROR    =  60;
  static const INTERNAL =  70;
  static const CRITICAL =  80;
  static const OFF      = 100;
}

class Log {
  final int       level;
  final DateTime  date;
  final String    code;
  final String    domain;
  final Map       argument;
  
  factory Log.fromBytes(Uint8List bytes) {
    final buffer = new Buffer.fromBytes(bytes);
    final level = buffer.getByte();
    final date = buffer.getUint64();
    // TODO deserialization
    return new Log(Level.ALL, '_unknown', null, '.', new DateTime.now());
  }
  
  Log(this.level, this.code, this.argument, this.domain, this.date);
  
  Log.now(this.level, this.code, this.argument, this.domain)
      : date = new DateTime.now();
  
  Uint8List toBytes() {
    final buffer = new Buffer();
    buffer.addByte(level);
    buffer.addUint64(date.millisecondsSinceEpoch);
    return buffer.bytes;
  }
  
  String toString() {
    final buffer = new StringBuffer();
    buffer.write('Log(code:"$code"');
    if (argument != null) buffer.write(', argument:$argument');
    buffer.write(', level:$level, date:"$date"');
    if (domain != null) buffer.write(', domain:$domain');
    buffer.write(')');
    return buffer.toString();
  }
}

class Logger {
  final _listeners = <LogListener>[];
  
  Logger._();
  
  int _level = Level.OFF;
  /// The current level of the logger.
  int get level => _level;
  
  /// Indicates if there are listeners for the given level.
  bool isLoggable(int level) => level >= _level;
  
  void _updateLevel() {
    _listeners.fold(Level.OFF,
        (int level, LogListener listener) =>
            listener.level < level ? listener.level : level);
  }
  
  /// Adds a log [listener] to the logger.
  void addListener(LogListener listener) {
    _listeners.add(listener);
    _updateLevel();
  }
  
  /// Removes a log [listener] from the logger.
  void removeListener(LogListener listener) {
    _listeners.remove(listener);
    _updateLevel();
  }
  
  void log(Log log) {
    _listeners
      .where((listener) => listener.level <= log.level)
      .forEach((listener) => listener.onLog(log));
  }
  
  /// Logs with the [Level.DEBUG] level.
  void debug(String code, [argument, String domain]) {
    if (isLoggable(Level.DEBUG))
      log(new Log.now(Level.DEBUG, code, argument, domain));
  }
  
  /// Logs with the [Level.INFO] level.
  void info(String code, [argument, String domain]) {
    if (isLoggable(Level.INFO))
      log(new Log.now(Level.INFO, code, argument, domain));
  }
  
  /// Logs with the [Level.CONFIG] level.
  void config(String code, [argument, String domain]) =>
      log(new Log.now(Level.CONFIG, code, argument, domain));
  
  /// Logs with the [Level.OK] level.
  void ok(String code, [argument, String domain]) =>
      log(new Log.now(Level.OK, code, argument, domain));
  
  /// Logs with the [Level.WARNING] level.
  void warn(String code, [argument, String domain]) =>
      log(new Log.now(Level.WARNING, code, argument, domain));
  
  /// Logs with the [Level.ERROR] level.
  void error(String code, [argument, String domain]) =>
      log(new Log.now(Level.ERROR, code, argument, domain));
  
  /// Logs with the [Level.INTERNAL] level.
  void internal(String code, [argument, String domain]) =>
      log(new Log.now(Level.INTERNAL, code, argument, domain));
  
  /// Logs with the [Level.CRITICAL] level.
  void critical(String code, [argument, String domain]) =>
      log(new Log.now(Level.CRITICAL, code, argument, domain));
}

abstract class LogListener {
  /// Gets the level of the listener.
  int get level;
  /// Handles a log instance.
  void onLog(Log log);
}
