import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/data/repositories/admin_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsScreen> createState() =>
      _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(adminRepositoryProvider);
      final data = await repo.getAnalytics();
      if (mounted)
        setState(() {
          _data = data;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.arena))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text('Error: $_error', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _data == null
                  ? const Center(child: Text('Sin datos'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: _buildContent(),
                    ),
    );
  }

  Widget _buildContent() {
    final data = _data!;
    final monthlySales = (data['monthlySales'] as num?)?.toDouble() ?? 0.0;
    final monthlyRefunds = (data['monthlyRefunds'] as num?)?.toDouble() ?? 0.0;
    final netSales = monthlySales - monthlyRefunds;
    final pendingOrders = (data['pendingOrders'] as num?)?.toInt() ?? 0;
    final pendingReturns = (data['pendingReturns'] as num?)?.toInt() ?? 0;
    final monthlyOrderCount = (data['monthlyOrderCount'] as num?)?.toInt() ?? 0;
    final totalCustomers = (data['totalCustomers'] as num?)?.toInt() ?? 0;
    final topProduct = data['topProduct'] as Map<String, dynamic>? ?? {};
    final chartData = (data['chartData'] as List?) ?? [];

    final monthName = DateFormat.MMMM('es_ES').format(DateTime.now());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Row 1: Net sales + Pending orders
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.euro,
                iconBg: const Color(0xFFD1FAE5),
                iconColor: const Color(0xFF059669),
                title: 'Ventas netas de $monthName',
                value: '${netSales.toStringAsFixed(2)}€',
                subtitle:
                    '$monthlyOrderCount pedidos · ${monthlySales.toStringAsFixed(2)}€ bruto',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                icon: Icons.access_time,
                iconBg: pendingOrders > 0
                    ? const Color(0xFFFEF3C7)
                    : const Color(0xFFF3F4F6),
                iconColor: pendingOrders > 0
                    ? const Color(0xFFD97706)
                    : AppColors.textSecondary,
                title: 'Pedidos pendientes',
                value: '$pendingOrders',
                subtitle: 'Requieren atención',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Returns + Top product
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.assignment_return,
                iconBg: pendingReturns > 0
                    ? const Color(0xFFFEE2E2)
                    : const Color(0xFFF3F4F6),
                iconColor: pendingReturns > 0
                    ? AppColors.error
                    : AppColors.textSecondary,
                title: 'Devoluciones',
                value: '${monthlyRefunds.toStringAsFixed(2)}€',
                subtitle: pendingReturns > 0
                    ? '$pendingReturns pendiente${pendingReturns > 1 ? 's' : ''}'
                    : 'Sin devoluciones pendientes',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                icon: Icons.emoji_events,
                iconBg: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF7C3AED),
                title: 'Más vendido',
                value: topProduct['name'] ?? 'Sin datos',
                valueSize: 14,
                subtitle: '${topProduct['quantity'] ?? 0} uds vendidas',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 3: Customers + Balance
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.people_outline,
                iconBg: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF2563EB),
                title: 'Clientes registrados',
                value: '$totalCustomers',
                subtitle: 'Total de la tienda',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                icon: Icons.bar_chart,
                iconBg: netSales >= 0
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFFEE2E2),
                iconColor:
                    netSales >= 0 ? const Color(0xFF059669) : AppColors.error,
                title: 'Balance $monthName',
                value:
                    '${netSales >= 0 ? '+' : ''}${netSales.toStringAsFixed(2)}€',
                valueColor:
                    netSales >= 0 ? const Color(0xFF059669) : AppColors.error,
                subtitle: 'Ventas − Devoluciones',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Weekly sales chart
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.arenaLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.arenaPale,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bar_chart,
                        color: AppColors.arena, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ventas - Últimos 7 días',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        Text('Ingresos diarios de pedidos pagados',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildChart(chartData),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<dynamic> chartData) {
    if (chartData.isEmpty ||
        chartData.every((d) => ((d['total'] as num?) ?? 0) == 0)) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_bag_outlined,
                  size: 40, color: AppColors.textSecondary),
              const SizedBox(height: 8),
              Text('No hay ventas en los últimos 7 días',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    final labels = <String>[];
    double maxY = 0;

    for (int i = 0; i < chartData.length; i++) {
      final item = chartData[i] as Map<String, dynamic>;
      final total = ((item['total'] as num?) ?? 0).toDouble();
      spots.add(FlSpot(i.toDouble(), total));
      labels.add(item['date']?.toString() ?? '');
      if (total > maxY) maxY = total;
    }

    maxY = maxY == 0 ? 100 : maxY * 1.2;

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.arenaLight,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}€',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        labels[idx],
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (chartData.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(2)}€',
                    const TextStyle(
                      color: AppColors.arena,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: const Color(0xFF8B7355),
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFF8B7355),
                    strokeWidth: 2,
                    strokeColor: AppColors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.arena.withOpacity(0.3),
                    AppColors.arena.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String value;
  final double? valueSize;
  final Color? valueColor;
  final String subtitle;

  const _KpiCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.value,
    this.valueSize,
    this.valueColor,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.arenaLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: valueSize ?? 22,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
