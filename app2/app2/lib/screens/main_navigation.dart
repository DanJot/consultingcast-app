import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/company.dart';
import 'personal_account_page.dart';
import 'company_page.dart';
import 'tasks_page.dart';

class MainNavigation extends StatefulWidget {
  final User user;
  final int initialIndex; // 0: Minha Empresa, 1: Home, 2: Conta Pessoal
  final Company? selectedCompany;

  const MainNavigation({
    super.key, 
    required this.user, 
    this.initialIndex = 0,
    this.selectedCompany,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  // Lista de páginas disponíveis
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 2);
    _pages = [
      CompanyPage(user: widget.user, selectedCompany: widget.selectedCompany),
      TasksPage(user: widget.user, selectedCompany: widget.selectedCompany),
      PersonalAccountPage(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0EA5E9),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              activeIcon: Icon(Icons.business),
              label: 'Minha Empresa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist),
              activeIcon: Icon(Icons.checklist),
              label: 'Tarefas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              activeIcon: Icon(Icons.person),
              label: 'Conta Pessoal',
            ),
          ],
        ),
      ),
    );
  }
}

