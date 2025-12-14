import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TimeLimiterPage extends StatefulWidget {
  const TimeLimiterPage({super.key});

  @override
  State<TimeLimiterPage> createState() => _TimeLimiterPageState();
}

class _TimeLimiterPageState extends State<TimeLimiterPage> {
  bool _timeLimitEnabled = true;
  int _dailyLimit = 120; // minutes
  int _todayUsage = 85; // minutes
  bool _breakReminders = true;
  bool _bedtimeMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return CustomScrollView(
            slivers: [
              _buildAppBar(isTablet),
              SliverPadding(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildUsageOverview(isTablet),
                    SizedBox(height: isTablet ? 32 : 24),
                    _buildTimeLimitSection(isTablet),
                    SizedBox(height: isTablet ? 32 : 24),
                    _buildWellbeingSection(isTablet),
                    SizedBox(height: isTablet ? 32 : 24),
                    _buildInsightsSection(isTablet),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      floating: true,
      snap: true,
      expandedHeight: isTablet ? 120 : 100,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient.scale(0.1),
          ),
        ),
        title: Text(
          'Digital Wellbeing',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      leading: Container(
        margin: EdgeInsets.only(
          left: isTablet ? 24 : 16,
          top: isTablet ? 12 : 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          border: Border.all(color: AppColors.border),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: isTablet ? 28 : 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildUsageOverview(bool isTablet) {
    final progress = _todayUsage / _dailyLimit;
    final remainingTime = _dailyLimit - _todayUsage;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        gradient: progress > 0.8 ? 
          LinearGradient(colors: [AppColors.error, AppColors.warning]) :
          AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(isTablet ? 28 : 20),
        boxShadow: [
          BoxShadow(
            color: (progress > 0.8 ? AppColors.error : AppColors.primary).withOpacity(0.3),
            blurRadius: isTablet ? 20 : 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Today\'s Usage',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            '${_todayUsage}m',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 56 : 48,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            remainingTime > 0 
              ? '${remainingTime}m remaining today'
              : 'Daily limit exceeded',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLimitSection(bool isTablet) {
    return _buildSection('Time Limits', [
      _buildSwitchItem(
        Icons.timer,
        'Daily Time Limit',
        'Set a daily usage limit',
        _timeLimitEnabled,
        (value) => setState(() => _timeLimitEnabled = value),
        AppColors.primary,
        isTablet,
      ),
      if (_timeLimitEnabled) _buildTimeLimitSlider(isTablet),
      _buildActionItem(
        Icons.schedule,
        'App Time Limits',
        'Set limits for specific apps',
        AppColors.secondary,
        isTablet,
      ),
    ], isTablet);
  }

  Widget _buildTimeLimitSlider(bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Limit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${_dailyLimit}m',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: _dailyLimit.toDouble(),
              min: 30,
              max: 480,
              divisions: 15,
              onChanged: (value) => setState(() => _dailyLimit = value.round()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellbeingSection(bool isTablet) {
    return _buildSection('Wellbeing Features', [
      _buildSwitchItem(
        Icons.notifications_pause,
        'Break Reminders',
        'Get reminded to take breaks',
        _breakReminders,
        (value) => setState(() => _breakReminders = value),
        AppColors.info,
        isTablet,
      ),
      _buildSwitchItem(
        Icons.bedtime,
        'Bedtime Mode',
        'Reduce distractions at night',
        _bedtimeMode,
        (value) => setState(() => _bedtimeMode = value),
        AppColors.warning,
        isTablet,
      ),
      _buildActionItem(
        Icons.focus_video,
        'Focus Mode',
        'Block distracting features',
        AppColors.success,
        isTablet,
      ),
    ], isTablet);
  }

  Widget _buildInsightsSection(bool isTablet) {
    return _buildSection('Usage Insights', [
      _buildInsightItem('Most Active Day', 'Monday', Icons.calendar_today, isTablet),
      _buildInsightItem('Peak Usage Time', '8:00 PM', Icons.access_time, isTablet),
      _buildInsightItem('Weekly Average', '95m/day', Icons.trending_up, isTablet),
      _buildInsightItem('Longest Session', '45 minutes', Icons.timer, isTablet),
    ], isTablet);
  }

  Widget _buildSection(String title, List<Widget> items, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: isTablet ? 8 : 4,
            bottom: isTablet ? 16 : 12,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: isTablet ? 15 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSwitchItem(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    Color iconColor,
    bool isTablet,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, String subtitle, Color iconColor, bool isTablet) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightItem(String title, String value, IconData icon, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}