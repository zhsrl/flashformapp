import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/features/home/widgets/home_appbar.dart';
import 'package:flashform_app/features/tables/providers/stats_provider.dart';
import 'package:flashform_app/features/tables/widgets/lead_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LeadsViewDesktop extends ConsumerWidget {
  const LeadsViewDesktop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: HomeAppBar(),
      body: statsAsync.when(
        data: (stats) {
          if (stats.isEmpty) {
            return Center(
              child: Text(
                'Нет созданных форм',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisExtent: 180,
                  mainAxisSpacing: 16,
                  maxCrossAxisExtent: 200,
                  crossAxisSpacing: 16,
                ),
                itemCount: stats.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return LeadCard(
                    stats: stats[index],
                    onTap: () {
                      context.go('/detail/${stats[index].id}');
                    },
                  );
                },
              ),
            ),
          );
        },
        loading: () => Center(
          child: LoadingAnimationWidget.waveDots(
            color: AppTheme.secondary,
            size: 50,
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ошибка загрузки'),
              const SizedBox(height: 16),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
