import 'package:flutter/material.dart';

import '../models/item_model.dart';
import 'login_screen.dart';

// =========================================================================
// SCREEN 3 — USER DASHBOARD & DETAIL USER
// User hanya dapat MELIHAT data (tidak ada tombol tambah/hapus/ubah).
// =========================================================================
class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  UserAccount get _account => AppData.currentUser!;
  List<ItemModel> get _items => AppData.items;

  int get _selesaiCount =>
      _items.where((i) => i.status == TaskStatus.selesai).length;
  int get _pendingCount => _items.length - _selesaiCount;

  // ---- Bottom sheet profil (dengan logo SMKN 1 Beringin) ----
  void _showProfile() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: _kGradientStart.withValues(alpha: 0.25), width: 2),
              ),
              child: const _SchoolLogo(size: 76),
            ),
            const SizedBox(height: 12),
            const Text('SMKN 1 Beringin',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kGradientStart)),
            const SizedBox(height: 10),
            Text(_account.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_account.email,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 6),
            Chip(
              label: const Text('User'),
              backgroundColor: _kGradientStart.withValues(alpha: 0.1),
              labelStyle: const TextStyle(
                  color: _kGradientStart, fontWeight: FontWeight.w600),
              side: BorderSide.none,
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kPageBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ProfileStat(label: 'Total', value: '${_items.length}'),
                  _ProfileStat(label: 'Selesai', value: '$_selesaiCount'),
                  _ProfileStat(label: 'Pending', value: '$_pendingCount'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _confirmLogout(context);
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label:
                    const Text('Keluar', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(ItemModel item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              children: [
                _ItemAvatar(item: item, size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(item.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _DetailRow(label: 'Kategori', value: item.category),
            const SizedBox(height: 8),
            _DetailRow(label: 'Status', value: item.statusLabel),
            const SizedBox(height: 8),
            _DetailRow(label: 'Ditambahkan oleh', value: item.addedBy),
            if (item.description != null && item.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _DetailRow(label: 'Keterangan', value: item.description!),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;

    return Scaffold(
      backgroundColor: _kPageBg,
      appBar: AppBar(
        backgroundColor: _kPageBg,
        surfaceTintColor: _kPageBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Row(
          children: [
            Icon(Icons.inventory_2_rounded, color: _kGradientStart, size: 22),
            SizedBox(width: 10),
            Text(
              'TASK & INVENTORY',
              style: TextStyle(
                color: _kTextDark,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showProfile,
            tooltip: 'Profil',
            icon: const Icon(Icons.person_rounded, color: _kGradientStart),
          ),
          IconButton(
            onPressed: () => _confirmLogout(context),
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded, color: _kGradientStart),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: GestureDetector(
                    onTap: _showProfile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_kGradientStart, _kGradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const _SchoolLogo(size: 52),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SMKN 1 BERINGIN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Halo, ${_account.name}! Lihat task dan inventory sekolah',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _StatCard(
                        icon: Icons.inventory_2_rounded,
                        label: 'TOTAL',
                        value: '${items.length}',
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        icon: Icons.check_circle_rounded,
                        label: 'SELESAI',
                        value: '$_selesaiCount',
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        icon: Icons.more_horiz_rounded,
                        label: 'PENDING',
                        value: '$_pendingCount',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                // ---- Info mode lihat saja ----
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _kGradientStart.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: _kGradientStart, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Mode lihat saja. Anda tidak dapat mengubah data.',
                            style: TextStyle(
                                color: _kGradientStart, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.view_list_rounded,
                          color: _kGradientStart, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'INVENTORY / TASK LIST',
                        style: TextStyle(
                          color: _kTextDark,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          if (items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = items[index];
                  return _TaskListTile(
                    item: item,
                    onDetail: () => _showDetail(item),
                  );
                },
                childCount: items.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// Kartu item untuk user: hanya ikon "lihat" (mata).
class _TaskListTile extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onDetail;

  const _TaskListTile({required this.item, required this.onDetail});

  @override
  Widget build(BuildContext context) {
    final bool selesai = item.status == TaskStatus.selesai;
    final Color statusColor =
        selesai ? const Color(0xFF16A34A) : const Color(0xFFEA580C);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _ItemAvatar(item: item),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                        color: _kTextDark)),
                const SizedBox(height: 4),
                Text('Kategori: ${item.category}',
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12.5)),
                const SizedBox(height: 6),
                Text(item.statusLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          IconButton(
            onPressed: onDetail,
            tooltip: 'Detail',
            icon: Icon(Icons.visibility_rounded, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// WIDGET & HELPER (privat di file ini)
// =========================================================================
const _kGradientStart = Color(0xFF4F46E5); // indigo
const _kGradientEnd = Color(0xFF7C3AED); // violet
const _kPageBg = Color(0xFFF5F6FA);
const _kCardBg = Colors.white;
const _kTextDark = Color(0xFF1F2430);

BoxDecoration _cardDecoration([double radius = 18]) => BoxDecoration(
      color: _kCardBg,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );

Future<bool> _confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  Color confirmColor = Colors.red,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: confirmColor),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result == true;
}

Future<void> _confirmLogout(BuildContext context) async {
  final ok = await _confirmDialog(
    context,
    title: 'Keluar?',
    message: 'Anda akan kembali ke halaman login.',
    confirmLabel: 'Keluar',
    confirmColor: _kGradientStart,
  );
  if (ok && context.mounted) {
    AppData.currentUser = null;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

// Logo SMKN 1 Beringin (assets/images/logo_smkn1.png).
// Jika file belum ada, tampil ikon sekolah sebagai pengganti.
class _SchoolLogo extends StatelessWidget {
  final double size;
  const _SchoolLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        'assets/images/logo_smkn1.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          color: Colors.white,
          child: Icon(Icons.school_rounded,
              color: _kGradientStart, size: size * 0.5),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _kGradientStart)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11.5)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _kGradientStart.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _kGradientStart, size: 18),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    color: _kTextDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('Belum ada data',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Data akan muncul di sini',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        ),
        Expanded(
          child: Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ),
      ],
    );
  }
}

class _ItemAvatar extends StatelessWidget {
  final ItemModel item;
  final double size;
  const _ItemAvatar({required this.item, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _kGradientStart.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(
        kCategoryIcons[item.category] ?? Icons.inventory_2_rounded,
        color: _kGradientStart,
        size: size * 0.5,
      ),
    );
  }
}