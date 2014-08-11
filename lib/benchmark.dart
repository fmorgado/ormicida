library ormicida.benchmark;

class Score {
  final String  name;
  final num     value;
  
  const Score(this.name, this.value);
}

class ScoreSet {
  final String name;
  final List<Score> scores;
  
  const ScoreSet(this.name, this.scores);
}

void _printScore(Score score) {
  print('${score.name}:  ${score.value.toStringAsFixed(4)}');
}

void _printScoreSet(ScoreSet scoreSet) {
  final maxLen = scoreSet.scores.fold(0,
      (int current, Score score) =>
        score.name.length > current ? score.name.length : current);
  final minValue = scoreSet.scores.fold(double.MAX_FINITE,
      (num current, Score score) =>
          score.value < current ? score.value : current);
  scoreSet.scores.sort(
      (Score score1, Score score2) =>
          score1.value.compareTo(score2.value));
  
  final buffer = new StringBuffer();
  buffer.writeln('####  ${scoreSet.name}');
  
  void _pad(int code, int length) {
    while (length-- > 0) buffer.writeCharCode(code);
  }
  void _padLeft(String label, int length) {
    _pad(32, length - label.length);
    buffer.write(label);
  }
  void _padRight(String label, int length) {
    buffer.write(label);
    _pad(32, length - label.length);
  }
  void _printScore(Score score) {
    buffer.write('      ');
    _padRight(score.name, maxLen + 2);
    _padLeft(score.value.toStringAsFixed(4), 14);
    _padLeft((score.value / minValue).toStringAsFixed(2), 8);
    buffer.writeln();
  }
  
  scoreSet.scores.forEach(_printScore);
  print(buffer.toString());
}

typedef void ScoreEmitter(Score score);
typedef void ScoreSetEmitter(ScoreSet scoreSet);

class Benchmark {
  static double measureFor(Function f, int timeMinimum) {
    int time = 0;
    int iter = 0;
    Stopwatch watch = new Stopwatch();
    watch.start();
    int elapsed = 0;
    while (elapsed < timeMinimum) {
      f();
      elapsed = watch.elapsedMilliseconds;
      iter++;
    }
    return 1000.0 * elapsed / iter;
  }
  
  final String        name;
  final ScoreEmitter  emitter;
  
  const Benchmark(this.name, {this.emitter: _printScore});
  
  /// The benchmark code.
  void run() {}
  
  /// Initialize the benchmark.
  void setup() {}
  
  /// De-initializes the benchmark.
  void teardown() {}
  
  /// Exercises the benchmark.
  void exercise() {
    for (int i = 0; i < 10; i++) {
      run();
    }
  }
  
  /// Measures the score for the benchmark and returns it.
  double measure() {
    setup();
    // Warmup for at least 100ms. Discard result.
    measureFor(() { this.run(); }, 100);
    // Run the benchmark for at least 2000ms.
    double result = measureFor(() { this.exercise(); }, 2000);
    teardown();
    return result;
  }
  
  /// Get the score of the benchmark.
  Score getScore() => new Score(name, measure());
  
  /// Report the score of the benchmark.
  void report() {
    emitter(getScore());
  }
}

class BenchmarkSet {
  final String name;
  final ScoreSetEmitter emitter;
  final _benchs = <Benchmark>[];
  
  BenchmarkSet(this.name, {this.emitter: _printScoreSet});
  
  /// Adds a benchmark to the set.
  void add(Benchmark bench) {
    _benchs.add(bench);
  }
  
  /// Gets the score set.
  ScoreSet getScoreSet() {
    final scores = <Score>[];
    
    _benchs.forEach((bench) {
      scores.add(bench.getScore());
    });
    
    return new ScoreSet(name, scores);
  }
  
  /// Reports the benchmark scores.
  void report() {
    emitter(getScoreSet());
  }
}
