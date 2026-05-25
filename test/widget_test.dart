import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/quiz.dart';
import 'package:quiz_app/data/questions.dart';
import 'package:quiz_app/models/quiz_question.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('QuizQuestion model', () {
    test('stores text and answers correctly', () {
      const q = QuizQuestion('Test?', ['A', 'B', 'C', 'D']);
      expect(q.text, 'Test?');
      expect(q.answers, ['A', 'B', 'C', 'D']);
    });

    test('getShuffledAnswers returns all answers', () {
      const q = QuizQuestion('Test?', ['A', 'B', 'C', 'D']);
      final shuffled = q.getShuffledAnswers();
      expect(shuffled.length, 4);
      expect(shuffled.toSet(), {'A', 'B', 'C', 'D'});
    });

    test('getShuffledAnswers does not mutate original list', () {
      const q = QuizQuestion('Test?', ['A', 'B', 'C', 'D']);
      q.getShuffledAnswers();
      expect(q.answers, ['A', 'B', 'C', 'D']);
    });
  });

  group('Questions data', () {
    test('questions list is not empty', () {
      expect(questions.isNotEmpty, true);
    });

    test('each question has exactly 4 answers', () {
      for (final q in questions) {
        expect(q.answers.length, 4);
      }
    });

    test('answers list matches questions length', () {
      expect(answers.length, questions.length);
    });

    test('each correct answer exists in its question options', () {
      for (int i = 0; i < questions.length; i++) {
        expect(questions[i].answers.contains(answers[i]), true);
      }
    });
  });

  group('Start screen', () {
    testWidgets('displays title text and start button', (tester) async {
      await tester.pumpWidget(const Quiz());
      await tester.pump();

      expect(find.text('Learn Flutter the fun way!'), findsOneWidget);
      expect(find.text('Start Quiz'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('tapping Start Quiz navigates to questions', (tester) async {
      await tester.pumpWidget(const Quiz());
      await tester.pump();

      await tester.tap(find.text('Start Quiz'));
      await tester.pumpAndSettle();

      expect(find.text(questions[0].text), findsOneWidget);
      expect(find.text('Start Quiz'), findsNothing);
    });
  });

  group('Questions screen', () {
    Future<void> goToQuestions(WidgetTester tester) async {
      await tester.pumpWidget(const Quiz());
      await tester.pump();
      await tester.tap(find.text('Start Quiz'));
      await tester.pumpAndSettle();
    }

    testWidgets('displays first question with answer buttons', (tester) async {
      await goToQuestions(tester);

      expect(find.text(questions[0].text), findsOneWidget);
      for (final answer in questions[0].answers) {
        expect(find.text(answer), findsOneWidget);
      }
    });

    testWidgets('tapping an answer advances to next question', (tester) async {
      await goToQuestions(tester);

      await tester.tap(find.text(questions[0].answers[0]));
      await tester.pumpAndSettle();

      expect(find.text(questions[1].text), findsOneWidget);
    });
  });

  group('Full quiz flow', () {
    Future<void> answerAllQuestions(
      WidgetTester tester, {
      bool correctly = true,
    }) async {
      await tester.pumpWidget(const Quiz());
      await tester.pump();

      await tester.tap(find.text('Start Quiz'));
      await tester.pumpAndSettle();

      for (int i = 0; i < questions.length; i++) {
        final answer = correctly
            ? answers[i]
            : questions[i].answers.firstWhere((a) => a != answers[i]);
        await tester.tap(find.text(answer));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('answering all correctly shows results screen', (tester) async {
      await answerAllQuestions(tester, correctly: true);

      final totalQuestions = questions.length;
      expect(
        find.textContaining('$totalQuestions out of $totalQuestions'),
        findsOneWidget,
      );
      expect(find.textContaining('Restart Quiz'), findsWidgets);
    });

    testWidgets('answering all incorrectly shows 0 score', (tester) async {
      await answerAllQuestions(tester, correctly: false);

      expect(
        find.textContaining('0 out of ${questions.length}'),
        findsOneWidget,
      );
    });

    testWidgets('results shows all question texts in summary', (tester) async {
      await answerAllQuestions(tester);

      for (final q in questions) {
        expect(find.text(q.text), findsOneWidget);
      }
    });

    testWidgets('restart returns to start screen', (tester) async {
      await answerAllQuestions(tester);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      expect(find.text('Learn Flutter the fun way!'), findsOneWidget);
      expect(find.text('Start Quiz'), findsOneWidget);
    });
  });

  group('Results screen details', () {
    Future<void> completeQuiz(WidgetTester tester) async {
      await tester.pumpWidget(const Quiz());
      await tester.pump();
      await tester.tap(find.text('Start Quiz'));
      await tester.pumpAndSettle();

      for (int i = 0; i < questions.length; i++) {
        await tester.tap(find.text(questions[i].answers[0]));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('shows correct answers for correct responses', (tester) async {
      await completeQuiz(tester);

      for (final answer in answers) {
        expect(find.text(answer), findsWidgets);
      }
    });

    testWidgets('shows green indicators for correct answers', (tester) async {
      await completeQuiz(tester);

      final greenContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == Colors.green &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(greenContainers, findsWidgets);
    });

    testWidgets('shows refresh icon button', (tester) async {
      await completeQuiz(tester);

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
