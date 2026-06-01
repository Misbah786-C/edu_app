import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:edu_app/main.dart';
import 'package:edu_app/controllers/auth_controller.dart';
import 'package:edu_app/screens/login_screen.dart';
import 'package:edu_app/screens/register_screen.dart';

void main() {
  // Helper to wrap a widget with the required Provider
  Widget withProvider(Widget child) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: MaterialApp(home: child),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(withProvider(const LoginScreen()));
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('shows error when submitting empty form', (tester) async {
      await tester.pumpWidget(withProvider(const LoginScreen()));
      // Sign In button should be disabled (onPressed == null) with empty fields
      final btn = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Sign In'));
      expect(btn.onPressed, isNull);
    });

    testWidgets('enables button when valid email and password entered', (tester) async {
      await tester.pumpWidget(withProvider(const LoginScreen()));
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'Hello@1');
      await tester.pump();
      final btn = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Sign In'));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('password field is obscured by default', (tester) async {
      await tester.pumpWidget(withProvider(const LoginScreen()));
      final passwordField = tester.widget<EditableText>(
        find.descendant(
          of: find.byType(TextFormField).at(1),
          matching: find.byType(EditableText),
        ),
      );
      expect(passwordField.obscureText, isTrue);
    });
  });

  group('RegisterScreen', () {
    testWidgets('renders all required fields', (tester) async {
      await tester.pumpWidget(withProvider(const RegisterScreen()));
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('submit button disabled when form is empty', (tester) async {
      await tester.pumpWidget(withProvider(const RegisterScreen()));
      final btn = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Create Account'));
      expect(btn.onPressed, isNull);
    });
  });

  group('EduApp smoke test', () {
    testWidgets('app launches and shows a Scaffold', (tester) async {
      await tester.pumpWidget(const EduApp());
      await tester.pump(); // let splash render
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}