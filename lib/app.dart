import 'package:expense_tracker/views/add_expense_page.dart';
import 'package:expense_tracker/views/add_income_page.dart';
import 'package:expense_tracker/views/expense_list_page.dart';
import 'package:expense_tracker/views/bottomnavbar.dart';
import 'package:expense_tracker/views/profileview.dart';
import 'package:expense_tracker/views/statistics.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => BottomNavBar(), // ✅ use your class
        '/add': (context) => AddExpensePage(),
        '/expenselist' : (context) => ExpenseListPage(),
        '/statistics' : (context) => StatisticsView(),
        '/add-income': (context) => const AddIncomePage(),

      },
    );
  }
}
