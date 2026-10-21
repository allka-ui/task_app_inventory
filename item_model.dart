import 'package:flutter/material.dart';

// =========================================================================
// MODEL — UserAccount & ItemModel
// =========================================================================
enum TaskStatus { belumSelesai, selesai }

// Tiga role:
//  - user        : hanya melihat data
//  - admin       : menambah, mengubah, dan menghapus data (tidak bisa
//                  mengelola akun)
//  - adminSuper  : semua hak admin, ditambah persetujuan akun baru
//                  dan pengaturan role
enum UserRole { user, admin, adminSuper }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.user:
        return 'User';
      case UserRole.admin:
        return 'Admin';
      case UserRole.adminSuper:
        return 'Super Admin';
    }
  }
}

class UserAccount {
  final String name;
  final String email;
  final String password;
  UserRole role; // bisa diubah oleh Super Admin
  bool isApproved; // sudah disetujui admin?
  bool isRejected; // ditolak admin?

  UserAccount({
    required this.name,
    required this.email,
    required this.password,
    this.role = UserRole.user,
    this.isApproved = false, // akun baru default: menunggu persetujuan
    this.isRejected = false,
  });

  // true untuk Admin maupun Super Admin (semua petugas pengelola).
  bool get isAdmin => role == UserRole.admin || role == UserRole.adminSuper;
  bool get isSuperAdmin => role == UserRole.adminSuper;
  String get roleLabel => role.label;

  // ---- Hak akses ----
  bool get canView => true;
  bool get canAdd => isAdmin;
  bool get canEdit => isAdmin;
  bool get canDelete => isAdmin;
  bool get canManageAccounts => isSuperAdmin;

  // Akun yang masih menunggu keputusan admin.
  bool get isPending => !isApproved && !isRejected;
}

class ItemModel {
  final String id;
  final String name;
  final String category;
  TaskStatus status;
  final String? description;
  final String addedBy; // nama admin yang menambahkan data

  ItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.addedBy,
    this.description,
  });

  String get statusLabel =>
      status == TaskStatus.selesai ? 'Selesai' : 'Belum Selesai';
}

// Ikon kategori, dipakai bersama di Dashboard & Form
const Map<String, IconData> kCategoryIcons = {
  'Elektronik': Icons.devices_other_rounded,
  'Alat Tulis': Icons.edit_note_rounded,
  'Perlengkapan': Icons.backpack_rounded,
  'Tugas': Icons.menu_book_rounded,
};

// =========================================================================
// PENYIMPANAN DATA SEMENTARA (in-memory)
// Ganti dengan database / API (Firebase, REST, dll) bila sudah tersedia.
// =========================================================================
class AppData {
  static final List<UserAccount> users = [
    // Super Admin default: langsung aktif, tidak perlu persetujuan.
    UserAccount(
      name: 'Admin',
      email: 'allkahardiansyah173@gmail.com',
      password: '123456',
      role: UserRole.adminSuper,
      isApproved: true,
    ),
    // Akun user contoh: sudah disetujui supaya tetap bisa login.
    UserAccount(
      name: 'Allka',
      email: 'babangsigma173@gmail.com',
      password: '123456',
      isApproved: true,
    ),
  ];

  // Data inventory/task: user hanya melihat, admin dan super admin dapat
  // menambah, mengubah, dan menghapus.
  static final List<ItemModel> items = [
    ItemModel(
      id: '1',
      name: 'Laptop Acer',
      category: 'Elektronik',
      status: TaskStatus.selesai,
      addedBy: 'Admin',
    ),
    ItemModel(
      id: '2',
      name: 'Laporan Praktikum',
      category: 'Tugas',
      status: TaskStatus.belumSelesai,
      addedBy: 'Admin',
    ),
    ItemModel(
      id: '3',
      name: 'Spidol Whiteboard',
      category: 'Alat Tulis',
      status: TaskStatus.belumSelesai,
      addedBy: 'Admin',
    ),
  ];

  // Akun yang sedang login
  static UserAccount? currentUser;

  // -----------------------------------------------------------------------
  // OPERASI DATA DENGAN PENGECEKAN ROLE
  // Semua perubahan data harus lewat sini, supaya hak akses tetap dicek
  // walaupun tombol di tampilan lolos. Mengembalikan false bila ditolak.
  // -----------------------------------------------------------------------
  static bool addItem(ItemModel item) {
    if (!(currentUser?.canAdd ?? false)) return false;
    items.add(item);
    return true;
  }

  static bool updateItem(ItemModel updated) {
    if (!(currentUser?.canEdit ?? false)) return false;
    final index = items.indexWhere((i) => i.id == updated.id);
    if (index == -1) return false;
    items[index] = updated;
    return true;
  }

  static bool toggleStatus(ItemModel item) {
    if (!(currentUser?.canEdit ?? false)) return false;
    item.status = item.status == TaskStatus.selesai
        ? TaskStatus.belumSelesai
        : TaskStatus.selesai;
    return true;
  }

  static bool deleteItem(String id) {
    if (!(currentUser?.canDelete ?? false)) return false;
    items.removeWhere((i) => i.id == id);
    return true;
  }

  // Setujui / tolak akun baru (khusus Super Admin). Role akhir boleh
  // diubah saat menyetujui.
  static bool reviewAccount(
    UserAccount account, {
    required bool approve,
    UserRole? role,
  }) {
    if (!(currentUser?.canManageAccounts ?? false)) return false;
    if (approve) {
      account.role = role ?? account.role;
      account.isApproved = true;
      account.isRejected = false;
    } else {
      account.isApproved = false;
      account.isRejected = true;
    }
    return true;
  }

  // Ubah role akun yang sudah aktif (khusus Super Admin, bukan akun sendiri).
  static bool changeRole(UserAccount account, UserRole role) {
    if (!(currentUser?.canManageAccounts ?? false)) return false;
    if (identical(account, currentUser)) return false;
    account.role = role;
    return true;
  }
}