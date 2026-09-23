import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:provider/provider.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/score_history_view_model.dart';

class ScoreHistorySection extends StatelessWidget {
  const ScoreHistorySection({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScoreHistoryViewModel(userId: userId),
      child: const _ScoreHistoryContent(),
    );
  }
}

class _ScoreHistoryContent extends StatelessWidget {
  const _ScoreHistoryContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<ScoreHistoryViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Score History',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Track how your reliability score has changed over time.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 14),

            ...viewModel.history.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildHistoryCard(context, viewModel, item),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    ScoreHistoryViewModel viewModel,
    ScoreHistoryItem item,
  ) {
    final isPositive = item.score >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Trending icon
          Icon(
            isPositive
                ? MingCuteIcons.mgc_trending_up_fill
                : MingCuteIcons.mgc_trending_down_fill,
            color: isPositive ? AppColors.green : AppColors.red,
            size: 26,
          ),

          const SizedBox(width: 12),

          // Trip information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${item.tripName} — ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return viewModel
                            .getStatusGradient(item.status)
                            .createShader(bounds);
                      },
                      child: Icon(
                        viewModel.getStatusIcon(item.status),
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${viewModel.getStatusText(item.status)}.',
                      style: TextStyle(
                        color: viewModel.getStatusColor(item.status),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  _formatDate(item.tripDate),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Score
          Text(
            isPositive ? '+${item.score}' : '${item.score}',
            style: TextStyle(
              color: isPositive ? AppColors.green : AppColors.red,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
