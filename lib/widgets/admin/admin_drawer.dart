import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    'https://ui-avatars.com/api/?name=Admin&background=random',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Admin Panel',
                  style: AppTextStyles.headerMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => context.go('/admin'),
          ),
          ListTile(
            leading: const Icon(Icons.sports_soccer),
            title: const Text('Kelola Lapangan'),
            onTap: () => context.push('/admin/fields'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Keluar'),
            onTap: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}
