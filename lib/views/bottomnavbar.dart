import 'package:expense_tracker/views/add_income_page.dart';
import 'package:expense_tracker/views/homepage.dart';
import 'package:expense_tracker/views/profileview.dart';
import 'package:expense_tracker/views/statistics.dart';
import 'package:flutter/material.dart';

import '../viewmodels/expense_viewmodel.dart';
import 'add_expense_page.dart';
import 'expense_list_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    Homepage(),
    AddExpensePage(),
    AddIncomePage(),
    ExpenseListPage(),
    Consumer(
      builder: (context, ref, _) {
        final expenses = ref.watch(expenseViewModelProvider);
        // We give it a unique key based on expenses count
        return StatisticsView(key: ValueKey(expenses.length));
      },
    ),
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(  // keeps the state of each page
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.limeAccent,
        type: BottomNavigationBarType.fixed, // ✅ prevents shifting
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.money_off), label: "Add Expense"),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money_sharp), label: "Cash Income"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Activity"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Statistics"),
        ],
      ),

    );
  }
}
