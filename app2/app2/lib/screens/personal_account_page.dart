import 'package:flutter/material.dart';
import '../models/user.dart';
import 'login_page.dart';

class PersonalAccountPage extends StatefulWidget {
  final User user;

  const PersonalAccountPage({super.key, required this.user});

  @override
  State<PersonalAccountPage> createState() => _PersonalAccountPageState();
}

class _PersonalAccountPageState extends State<PersonalAccountPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _profileController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _profileController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    _profileController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Conta Pessoal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
              onPressed: _showLogoutDialog,
              tooltip: 'Terminar sessão',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8B5CF6),
              Color(0xFF6366F1),
              Color(0xFFF8FAFC),
            ],
            stops: [0.0, 0.4, 0.8],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProfileSection(),
                        const SizedBox(height: 24),
                        _buildQuickStats(),
                        const SizedBox(height: 28),
                        _buildSectionTitle('Gestão Pessoal'),
                        const SizedBox(height: 16),
                        _buildPersonalOptions(),
                        const SizedBox(height: 28),
                        _buildSectionTitle('Configurações'),
                        const SizedBox(height: 16),
                        _buildSettingsOptions(),
                        const SizedBox(height: 28),
                        _buildSecuritySection(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _profileController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _profileController.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.transparent,
                      child: Text(
                        widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              widget.user.name.isNotEmpty ? widget.user.name : 'Utilizador',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                widget.user.email,
                style: const TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF059669),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Usuário Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Documentos', '12', Icons.description_outlined, const Color(0xFF10B981)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Atividades', '28', Icons.timeline_outlined, const Color(0xFF8B5CF6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Empresas', '3', Icons.business_outlined, const Color(0xFF06B6D4)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildPersonalOptions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                'Perfil',
                'Dados pessoais',
                Icons.person_outlined,
                const Color(0xFF10B981),
                () => _showSnackBar('Perfil'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionCard(
                'Documentos',
                'Arquivos pessoais',
                Icons.folder_outlined,
                const Color(0xFF8B5CF6),
                () => _showSnackBar('Documentos'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                'Atividades',
                'Histórico pessoal',
                Icons.history_outlined,
                const Color(0xFFEF4444),
                () => _showSnackBar('Atividades'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionCard(
                'Notificações',
                'Alertas pessoais',
                Icons.notifications_outlined,
                const Color(0xFFF59E0B),
                () => _showSnackBar('Notificações'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsOptions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                'Privacidade',
                'Configurações privacidade',
                Icons.privacy_tip_outlined,
                const Color(0xFF6366F1),
                () => _showSnackBar('Privacidade'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionCard(
                'Segurança',
                'Senha e autenticação',
                Icons.security_outlined,
                const Color(0xFF059669),
                () => _showSnackBar('Segurança'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                'Aparência',
                'Tema e idioma',
                Icons.palette_outlined,
                const Color(0xFFEC4899),
                () => _showSnackBar('Aparência'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionCard(
                'Sobre',
                'Informações do app',
                Icons.info_outline,
                const Color(0xFF64748B),
                () => _showSnapshot(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.security_outlined,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ações de Segurança',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSecurityButton(
            'Alterar Senha',
            Icons.lock_outline,
            const Color(0xFF059669),
            () => _showSnackBar('Alterar Senha'),
          ),
          const SizedBox(height: 12),
          _buildSecurityButton(
            'Autenticação Dupla',
            Icons.verified_user_outlined,
            const Color(0xFF8B5CF6),
            () => _showSnackBar('Autenticação Dupla'),
          ),
          const SizedBox(height: 12),
          _buildSecurityButton(
            'Sessões Ativas',
            Icons.devices_outlined,
            const Color(0xFF06B6D4),
            () => _showSnackBar('Sessões Ativas'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: color.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF8B5CF6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSnapshot() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre o App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ConsultingCast v1.0'),
            const SizedBox(height: 8),
            const Text('Desenvolvido para consultoria empresarial'),
            const SizedBox(height: 8),
            Text(
              'Versão: 1.0.0',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Terminar Sessão'),
        content: const Text('Tem a certeza que pretende terminar a sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 194, 31, 31),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    
    if (confirm == true && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }
}