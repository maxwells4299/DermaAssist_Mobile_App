import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/scan.dart';
import '../utils/glass_morphism.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Scan> _scans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  Future<void> _loadScans() async {
    final user = await AuthService().getUser();
    if (user != null) {
      final userId = user['id'];
      final maps = await DatabaseService().getUserScans(userId);
      setState(() {
        _scans = maps.map((map) => Scan.fromMap(map)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int get highRiskCount => _scans.where((s) => s.probability >= 0.7).length;
  int get mediumRiskCount => _scans.where((s) => s.probability >= 0.4 && s.probability < 0.7).length;
  int get lowRiskCount => _scans.where((s) => s.probability < 0.4).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.grey[900];

    return GradientBackground(
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _scans.isEmpty
                ? Center(
                    child: Text(
                      'No scans found yet.',
                      style: TextStyle(color: primaryColor, fontSize: 18),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadScans,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Scan History & Analytics',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildRiskSummaryChart(isDark),
                            const SizedBox(height: 24),
                            if (_scans.length > 1) _buildTrendChart(isDark),
                            if (_scans.length > 1) const SizedBox(height: 24),
                            Text(
                              'Recent Scans',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._scans.map((scan) => _buildScanTile(scan, isDark)).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildRiskSummaryChart(bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Risk Category Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Colors.redAccent,
                    value: highRiskCount.toDouble(),
                    title: '$highRiskCount',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.orangeAccent,
                    value: mediumRiskCount.toDouble(),
                    title: '$mediumRiskCount',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.greenAccent,
                    value: lowRiskCount.toDouble(),
                    title: '$lowRiskCount',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegend(Colors.redAccent, 'High'),
              _buildLegend(Colors.orangeAccent, 'Medium'),
              _buildLegend(Colors.greenAccent, 'Low'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildTrendChart(bool isDark) {
    final reversedScans = _scans.reversed.toList();
    List<FlSpot> spots = [];
    for (int i = 0; i < reversedScans.length; i++) {
      spots.add(FlSpot(i.toDouble(), reversedScans[i].probability * 100));
    }

    return GlassContainer(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Melanoma Probability Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text('${value.toInt()}%', style: const TextStyle(fontSize: 10)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.deepPurpleAccent,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.deepPurpleAccent.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanTile(Scan scan, bool isDark) {
    final date = DateTime.parse(scan.date);
    final formattedDate = DateFormat('MMM d, yyyy - h:mm a').format(date);
    
    Color riskColor;
    String riskLabel;
    if (scan.probability >= 0.7) {
      riskColor = Colors.redAccent;
      riskLabel = 'High Risk';
    } else if (scan.probability >= 0.4) {
      riskColor = Colors.orangeAccent;
      riskLabel = 'Medium Risk';
    } else {
      riskColor = Colors.greenAccent;
      riskLabel = 'Low Risk';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(melanomaProbability: scan.probability),
            ),
          );
        },
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 48,
                decoration: BoxDecoration(
                  color: riskColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riskLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(scan.probability * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: riskColor,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white54 : Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
