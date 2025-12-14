import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/post_models.dart';

class PostInsightsPage extends StatefulWidget {
  final Post post;

  const PostInsightsPage({Key? key, required this.post}) : super(key: key);

  @override
  State<PostInsightsPage> createState() => _PostInsightsPageState();
}

class _PostInsightsPageState extends State<PostInsightsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '7d';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
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
                    'Insights',
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
                actions: [
                  Container(
                    margin: EdgeInsets.only(
                      right: isTablet ? 24 : 16,
                      top: isTablet ? 12 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: PopupMenuButton<String>(
                      onSelected: (period) => setState(() => _selectedPeriod = period),
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.textPrimary,
                        size: isTablet ? 28 : 24,
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: '1d', child: Text('Last 24 hours')),
                        const PopupMenuItem(value: '7d', child: Text('Last 7 days')),
                        const PopupMenuItem(value: '30d', child: Text('Last 30 days')),
                      ],
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.all(isTablet ? 24 : 16),
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
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
                  child: Row(
                    children: [
                      Container(
                        width: isTablet ? 80 : 60,
                        height: isTablet ? 80 : 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                          border: Border.all(color: AppColors.border),
                          image: DecorationImage(
                            image: NetworkImage(widget.post.media.first.url),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: isTablet ? 16 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.caption.length > 50
                                  ? '${widget.post.caption.substring(0, 50)}...'
                                  : widget.post.caption,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: isTablet ? 16 : 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: isTablet ? 6 : 4),
                            Text(
                              _formatDate(widget.post.createdAt),
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: isTablet ? 14 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w700,
                    ),
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Audience'),
                      Tab(text: 'Promotion'),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(isTablet),
                    _buildAudienceTab(isTablet),
                    _buildPromotionTab(isTablet),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics
          Row(
            children: [
              Expanded(child: _buildMetricCard('Likes', widget.post.insights.likes, Icons.favorite, isTablet: isTablet)),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(child: _buildMetricCard('Comments', widget.post.insights.comments, Icons.comment, isTablet: isTablet)),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Shares', widget.post.insights.shares, Icons.share, isTablet: isTablet)),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(child: _buildMetricCard('Saves', widget.post.insights.saves, Icons.bookmark, isTablet: isTablet)),
            ],
          ),
          const SizedBox(height: 24),

          // Engagement Chart
          const Text('Engagement Over Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 3),
                      const FlSpot(1, 1),
                      const FlSpot(2, 4),
                      const FlSpot(3, 2),
                      const FlSpot(4, 5),
                      const FlSpot(5, 3),
                      const FlSpot(6, 4),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Performance Metrics
          const Text('Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPerformanceMetric('Reach', widget.post.insights.reach, 'accounts reached'),
          _buildPerformanceMetric('Impressions', widget.post.insights.impressions, 'times your post was seen'),
          _buildPerformanceMetric('Profile visits', 45, 'visits to your profile'),
          _buildPerformanceMetric('Website clicks', 12, 'clicks to your website'),
          const SizedBox(height: 24),

          // Actions
          const Text('Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (widget.post.promotion == null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _promotePost,
                icon: const Icon(Icons.trending_up),
                label: const Text('Promote Post'),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _shareInsights,
              icon: const Icon(Icons.share),
              label: const Text('Share Insights'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Demographics
          const Text('Demographics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Age Groups
          const Text('Age Groups', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          _buildDemographicBar('18-24', 35, Colors.blue),
          _buildDemographicBar('25-34', 45, Colors.green),
          _buildDemographicBar('35-44', 15, Colors.orange),
          _buildDemographicBar('45+', 5, Colors.red),
          const SizedBox(height: 24),

          // Gender
          const Text('Gender', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          _buildDemographicBar('Female', 60, Colors.pink),
          _buildDemographicBar('Male', 38, Colors.blue),
          _buildDemographicBar('Other', 2, Colors.purple),
          const SizedBox(height: 24),

          // Top Locations
          const Text('Top Locations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          _buildLocationItem('United States', 45),
          _buildLocationItem('United Kingdom', 20),
          _buildLocationItem('Canada', 15),
          _buildLocationItem('Australia', 10),
          _buildLocationItem('Germany', 8),
        ],
      ),
    );
  }

  Widget _buildPromotionTab(bool isTablet) {
    if (widget.post.promotion == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.trending_up, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No active promotion', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('Promote this post to reach more people', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _promotePost,
              child: const Text('Promote Post'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campaign Overview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.promotion!.campaignName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Budget: \$${widget.post.promotion!.budget.toStringAsFixed(2)}'),
                Text('Period: ${_formatDate(widget.post.promotion!.startDate)} - ${_formatDate(widget.post.promotion!.endDate)}'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Promotion Metrics
          const Text('Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Spent', 45, Icons.attach_money, subtitle: 'of \$${widget.post.promotion!.budget.toStringAsFixed(0)}')),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard('Reach', 1250, Icons.visibility)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Clicks', 89, Icons.touch_app)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard('CTR', 7.1, Icons.trending_up, subtitle: '%')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, dynamic value, IconData icon, {String? subtitle, bool isTablet = false}) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient.scale(0.05),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isTablet ? 10 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: isTablet ? 24 : 20,
                color: AppColors.primary,
              ),
              SizedBox(width: isTablet ? 10 : 8),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(String title, int value, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicBar(String label, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$percentage%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLocationItem(String location, int percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(location),
          Text('$percentage%', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _promotePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PromotePostSheet(
        post: widget.post,
        onPromotionCreated: (promotion) {
          // Handle promotion creation
          Navigator.pop(context);
        },
      ),
    );
  }

  void _shareInsights() {
    // Share insights functionality
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class PromotePostSheet extends StatefulWidget {
  final Post post;
  final Function(PostPromotion) onPromotionCreated;

  const PromotePostSheet({
    Key? key,
    required this.post,
    required this.onPromotionCreated,
  }) : super(key: key);

  @override
  State<PromotePostSheet> createState() => _PromotePostSheetState();
}

class _PromotePostSheetState extends State<PromotePostSheet> {
  final TextEditingController _budgetController = TextEditingController(text: '20');
  final TextEditingController _campaignNameController = TextEditingController();
  String _objective = 'awareness';
  int _duration = 7;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text('Promote Post', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Campaign Name
          TextField(
            controller: _campaignNameController,
            decoration: const InputDecoration(
              labelText: 'Campaign Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Objective
          const Text('Objective', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _objective,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'awareness', child: Text('Brand Awareness')),
              DropdownMenuItem(value: 'traffic', child: Text('Website Traffic')),
              DropdownMenuItem(value: 'engagement', child: Text('Engagement')),
              DropdownMenuItem(value: 'conversions', child: Text('Conversions')),
            ],
            onChanged: (value) => setState(() => _objective = value!),
          ),
          const SizedBox(height: 16),

          // Budget
          TextField(
            controller: _budgetController,
            decoration: const InputDecoration(
              labelText: 'Daily Budget (\$)',
              border: OutlineInputBorder(),
              prefixText: '\$ ',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Duration
          const Text('Duration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Slider(
            value: _duration.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            label: '$_duration days',
            onChanged: (value) => setState(() => _duration = value.round()),
          ),
          Text('$_duration days', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Estimated Results
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Results', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Reach: ${(double.parse(_budgetController.text) * _duration * 50).round()} people'),
                Text('Impressions: ${(double.parse(_budgetController.text) * _duration * 75).round()}'),
                Text('Total Budget: \$${(double.parse(_budgetController.text) * _duration).toStringAsFixed(2)}'),
              ],
            ),
          ),
          const Spacer(),

          // Create Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createPromotion,
              child: const Text('Create Promotion'),
            ),
          ),
        ],
      ),
    );
  }

  void _createPromotion() {
    final promotion = PostPromotion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      campaignName: _campaignNameController.text,
      budget: double.parse(_budgetController.text),
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: _duration)),
    );
    
    widget.onPromotionCreated(promotion);
  }
}