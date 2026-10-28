import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/models.dart';
import '../core/repository.dart';
import '../core/session.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<FoodstockRepository>();
    final version = context.select<SessionController, int>((s) => s.dataVersion);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
      ),
      body: AsyncView<List<NotificationItem>>(
        load: () async => (await repo.notifications()).items,
        reloadToken: version,
        builder: (context, list) {
          if (list.isEmpty) {
            return const [
              StateMessage(
                icon: Icons.notifications_off_outlined,
                title: 'Belum ada notifikasi',
                message: 'Informasi dan pemberitahuan penting sistem akan muncul di sini.',
              ),
            ];
          }
          return [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Pemberitahuan terbaru mengenai sistem dan peringatan pangan.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            for (final n in list)
              AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.accentMint : AppColors.emeraldDark).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        n.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                        color: isDark ? AppColors.accentMint : AppColors.emeraldDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  n.title,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.emeraldDark,
                                  ),
                                ),
                              ),
                              if (!n.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.tealGlow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            n.body,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? Colors.white70 : Colors.grey.shade700,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            Fmt.waktu(n.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ];
        },
      ),
    );
  }
}