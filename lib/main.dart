import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notifier dan State Management Riverpod
final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier();
});

void main() {
  runApp(const ProviderScope(child: FigmaToCodeApp()));
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      home: Scaffold(
        body: Center( // Menambahkan Center untuk keseluruhan ListView
          child: ListView(
            shrinkWrap: true, // Agar ListView menyesuaikan ukuran kontennya
            children: [
              QuizPage(),
            ],
          ),
        ),
      ),
    );
  }
}

// Notifier untuk State Management Riverpod
class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier() : super(QuizState());

  // Perbaikan fungsi answerQuestion untuk menerima jawaban user dan membandingkan dengan jawaban yang benar
  void answerQuestion(bool userAnswer) {
    // Ambil jawaban yang benar dari soal saat ini
    final correctAnswer = state.questions[state.currentQuestionIndex]['answer'] as bool;

    // Cek apakah jawaban user benar atau salah
    final isCorrect = userAnswer == correctAnswer;

    // Perbarui state dengan jawaban yang sesuai
    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
      correctAnswers: isCorrect ? state.correctAnswers + 1 : state.correctAnswers,
    );
  }

  void resetQuiz() {
    state = QuizState();
  }
}

// State untuk Quiz
class QuizState {
  final int currentQuestionIndex;
  final int correctAnswers;
  final List<Map<String, dynamic>> questions;

  QuizState({
    this.currentQuestionIndex = 0,
    this.correctAnswers = 0,
    this.questions = const [
      {"question": "Apakah Flutter menggunakan bahasa Dart?", "answer": true},
      {"question": "Apakah Flutter framework untuk backend?", "answer": false},
      {"question": "Apakah YES berarti YA?", "answer": true},
    ],
  });

  QuizState copyWith({
    int? currentQuestionIndex,
    int? correctAnswers,
  }) {
    return QuizState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      questions: questions,
    );
  }
}

// Halaman Quiz
class QuizPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final quizNotifier = ref.read(quizProvider.notifier);

    return Center( // Membuat keseluruhan tampilan berada di tengah
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Menambahkan padding opsional
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (quizState.currentQuestionIndex < quizState.questions.length) ...[
              // Menampilkan pertanyaan dan pilihan jawaban
              Text(
                'Pertanyaan ${quizState.currentQuestionIndex + 1}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 332,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF2C2C2C)),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    quizState.questions[quizState.currentQuestionIndex]['question'],
                    style: TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Pilih jawaban anda!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Kirim jawaban 'true' ketika tombol 'Benar' ditekan
                      quizNotifier.answerQuestion(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4287FF),
                    ),
                    child: Text('Benar', style: TextStyle(
                      color: Colors.white
                    ),),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Kirim jawaban 'false' ketika tombol 'Salah' ditekan
                      quizNotifier.answerQuestion(false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF04646),
                    ),
                    child: Text('Salah', style: TextStyle(
                      color: Colors.white
                    ),),
                  ),
                ],
              ),
            ] else ...[
              // Menampilkan hasil akhir setelah semua soal dijawab
              Text(
                'Quiz Selesai!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Nilai anda: ${(quizState.correctAnswers / quizState.questions.length * 100).toInt()}',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  quizNotifier.resetQuiz();
                },
                child: Text('Ulangi Quiz'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
