import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firebase_service.dart';
import '../main.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseService _firebase = FirebaseService();
  final Color primaryBrand = const Color(0xff6C63FF);

  // Graph State Variables
  List<FlSpot> energyPoints = [];
  double timeCount = 0;

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  void _updateGraphData(double usage) {
    if (energyPoints.length > 15) {
      energyPoints.removeAt(0);
    }
    energyPoints.add(FlSpot(timeCount, usage));
    timeCount += 1;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<DatabaseEvent>(
      stream: _firebase.dataStream,
      builder: (context, snapshot) {
        Map data = {};
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
        }

        double temp = (data['temperature'] ?? 0.0).toDouble();
        double hum = (data['humidity'] ?? 0.0).toDouble();
        int light = (data['light'] ?? 0).toInt();
        double usage = (data['usage'] ?? 0.0).toDouble();
        bool smartMode = _parseBool(data['isSmartMode']);
        
        _updateGraphData(usage);

        Map<String, bool> apps = {
          "Living Room Lights": _parseBool(data['LivingRoomLights']),
          "Fan": _parseBool(data['FanState']),
          "Test Load": (data['power'] ?? 0.0) > 2.0, // If instant power is > 2 Watts, it's ON // If usage is > 0, it's "On"
        };

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text("Energy AI Optimizer", 
              style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: Icon(themeNotifier.value == ThemeMode.light 
                    ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
                onPressed: () {
                  themeNotifier.value = themeNotifier.value == ThemeMode.light 
                      ? ThemeMode.dark : ThemeMode.light;
                },
              ),
              IconButton(
                onPressed: () => _firebase.logout(), 
                icon: const Icon(Icons.logout)
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDynamicAlert(temp, usage),
                const SizedBox(height: 20),
                _buildMainEnergyCard(usage, smartMode, data),
                const SizedBox(height: 25),
                
                const Row(
                  children: [
                    Icon(Icons.show_chart, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Text("Live Energy Consumption (kWh)", 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildEnergyGraph(isDark, usage),
                const SizedBox(height: 25),
                
                _buildSmartTip(light, smartMode, apps),
                const SizedBox(height: 25),
                _buildSmartModeCard(smartMode, isDark),
                const SizedBox(height: 25),
                
                const Text("Appliance Control", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildDeviceGrid(apps, smartMode, isDark),
                const SizedBox(height: 25),
                
                const Text("Environment Sensors", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildSensorGrid(temp, hum, light, isDark),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnergyGraph(bool isDark, double currentUsage) {
    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.only(right: 25, left: 10, top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: (currentUsage > 5) ? currentUsage + 2 : 10,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: primaryBrand, 
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((barSpot) {
                  return LineTooltipItem(
                    '${barSpot.y.toStringAsFixed(2)} kWh',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: isDark ? Colors.white10 : Colors.grey.shade100,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: energyPoints,
              isCurved: true,
              color: primaryBrand,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryBrand.withOpacity(0.3), primaryBrand.withOpacity(0.0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicAlert(double temp, double usage) {
    bool isCritical = temp > 40 || usage > 5.0;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isCritical ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isCritical ? Colors.red : Colors.green),
      ),
      child: Row(
        children: [
          Icon(isCritical ? Icons.warning_amber_rounded : Icons.check_circle_outline, 
               color: isCritical ? Colors.red : Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isCritical ? "CRITICAL: High Temp/Load Detected!" : "SYSTEM SECURE: Energy Efficiency Optimized",
              style: TextStyle(color: isCritical ? Colors.red : Colors.green, 
                               fontWeight: FontWeight.bold, fontSize: 13),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMainEnergyCard(double usage, bool smartMode, Map data) {
    double cost = usage * 7.5;
    double savings = smartMode ? (usage * 0.25) * 7.5 : 0.0;
    
    // --- START OF NEW CREDIBLE EFFICIENCY LOGIC ---
    int baseEfficiency = smartMode ? 92 : 75; // Smart mode starts much higher
    
    // Factor 1: Penalty for High Temperature (System Stress)
    double tempPenalty = (data['temperature'] ?? 25.0) > 35 ? 5 : 0;
    
    // Factor 2: Vampire Load Penalty
    // If usage is very low but constant, it's considered waste
    double vampirePenalty = (usage > 0.01 && usage < 0.1) ? 10 : 0;
    
    // Factor 3: Reward for Low Light Usage
    double optimizationReward = ((data['light'] ?? 500) > 600 && smartMode) ? 5 : 0;

    int efficiency = (baseEfficiency - tempPenalty - vampirePenalty + optimizationReward).toInt();
    
    // Keep it within a realistic human range (60% to 98%)
    if (efficiency > 98) efficiency = 98;
    if (efficiency < 60) efficiency = 60;
    // --- END OF NEW LOGIC ---

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryBrand, const Color(0xff483D8B)]),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: primaryBrand.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TOTAL CONSUMPTION", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text("${usage.toStringAsFixed(2)} kWh", 
               style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricColumn("Cost", "₹${cost.toStringAsFixed(2)}"),
              _buildMetricColumn("Savings", "₹${savings.toStringAsFixed(2)}"),
              _buildMetricColumn("Efficiency", "$efficiency%"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSmartTip(int light, bool smart, Map<String, bool> apps) {
    String tip = "AI analyzing ambient light and load patterns...";
    if (!smart) tip = "Enable AI Smart Mode to reduce waste by ~20%.";
    else if (light > 700 && (apps["Living Room Lights"] ?? false)) 
      tip = "Optimization Active: Dimming lights due to natural sunlight.";

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: primaryBrand.withOpacity(0.08), 
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_fix_high_rounded, color: primaryBrand, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(tip, style: TextStyle(color: primaryBrand, fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildSmartModeCard(bool isSmartMode, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white, 
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology_outlined, color: Color(0xff6C63FF)),
              SizedBox(width: 12),
              Text("AI Smart Mode", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          Switch(
            value: isSmartMode, 
            activeColor: primaryBrand, 
            onChanged: (val) => _firebase.toggleSmartMode(val)
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceGrid(Map<String, bool> appliances, bool smartMode, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.4),
      itemCount: appliances.length,
      itemBuilder: (context, index) {
        String key = appliances.keys.elementAt(index);
        bool isOn = appliances[key] ?? false;
        
        IconData deviceIcon;
        if (key == "Fan") deviceIcon = Icons.air_rounded;
        else if (key == "Living Room Lights") deviceIcon = Icons.lightbulb_outline;
        else deviceIcon = Icons.power_outlined;

        return InkWell(
          onTap: () async {
            if (key == "Test Load") {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Monitoring Only: This load has no relay control.")),
              );
              return; 
            }
            if (smartMode) {
              await _firebase.toggleSmartMode(false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Manual Control Detected: Smart Mode Disabled")),
              );
            }
            await _firebase.toggleDevice(key, !isOn);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isOn ? primaryBrand : (isDark ? Colors.white.withOpacity(0.05) : Colors.white), 
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isOn ? primaryBrand : (isDark ? Colors.white12 : Colors.grey.shade200))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(deviceIcon, color: isOn ? Colors.white : (isDark ? Colors.white38 : Colors.black38), size: 32),
                const SizedBox(height: 10),
                Text(key, style: TextStyle(
                  color: isOn ? Colors.white : (isDark ? Colors.white : Colors.black87), 
                  fontWeight: FontWeight.bold, fontSize: 13)),
                if (key == "Test Load" && isOn) 
                  const Text("Sensing Active", style: TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSensorGrid(double temp, double hum, int light, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSensorTile("${temp.toStringAsFixed(1)}°C", "Temp", Icons.thermostat, Colors.orange, isDark),
        _buildSensorTile("${hum.toStringAsFixed(0)}%", "Humidity", Icons.water_drop_outlined, Colors.blue, isDark),
        _buildSensorTile("$light lx", "Light", Icons.wb_sunny_outlined, Colors.amber, isDark),
      ],
    );
  }

  Widget _buildSensorTile(String val, String label, IconData icon, Color color, bool isDark) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}
