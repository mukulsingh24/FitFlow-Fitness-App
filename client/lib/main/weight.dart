import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController weightController = TextEditingController();

  bool isSaving = false;
  bool isLoadingHistory = true;

  List<dynamic> weightHistory = [];

  double? currentWeight;
  double? previousWeight;

  static const Color primary = Color(0xFF1DB954);
  static const Color primaryDark = Color(0xFF128C3F);
  static const Color scaffoldBg = Color(0xFFF6F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16201C);
  static const Color textMuted = Color(0xFF6B7570);
  static const Color softMint = Color(0xFFE4F5E8);
  static const Color border = Color(0xFFE7ECE8);

  @override
  void initState() {
    super.initState();
    loadWeightHistory();
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  Future<void> loadWeightHistory() async {
    setState(() {
      isLoadingHistory = true;
    });

    try {
      final history = await ApiService.getWeightHistory();

      if (!mounted) return;

      double? latest;
      double? previous;

      if (history.isNotEmpty) {
        latest = (history.first["weight"] as num).toDouble();

        if (history.length > 1) {
          previous = (history[1]["weight"] as num).toDouble();
        }
      }

      setState(() {
        weightHistory = history;
        currentWeight = latest;
        previousWeight = previous;
        isLoadingHistory = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        isLoadingHistory = false;
      });
    }
  }

  Future<void> saveWeight() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await ApiService.addWeight(
        weight: double.parse(weightController.text.trim()),
        notes: null,
      );

      weightController.clear();

      await loadWeightHistory();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Weight saved successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });
  }

  double? get weightDifference {
    if (currentWeight == null || previousWeight == null) {
      return null;
    }

    return currentWeight! - previousWeight!;
  }

  bool get hasGainedWeight {
    if (weightDifference == null) return false;

    return weightDifference! > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: RefreshIndicator(
                color: primary,
                onRefresh: loadWeightHistory,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildCurrentWeightCard(),
                      const SizedBox(height: 20),
                      _buildAddWeightCard(),
                      const SizedBox(height: 22),
                      _buildHistorySection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 20, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: textDark,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "FitFlow",
            style: TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: softMint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "WEIGHT",
              style: TextStyle(
                color: primaryDark,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: .6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        color: softMint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -10,
            child: Icon(
              Icons.monitor_weight,
              size: 90,
              color: primary.withOpacity(.14),
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TRACK YOUR PROGRESS",
                style: TextStyle(
                  color: primaryDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Weight Tracker",
                style: TextStyle(
                  color: textDark,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Monitor your weight journey and visualize your progress over time.",
                style: TextStyle(color: textMuted, fontSize: 13.5, height: 1.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.monitor_weight, color: Colors.white, size: 34),
          const SizedBox(height: 12),
          const Text(
            "CURRENT WEIGHT",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentWeight == null ? "--" : currentWeight!.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            "kg",
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 18),
          if (weightDifference != null) ...[
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasGainedWeight ? Icons.trending_up : Icons.trending_down,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${weightDifference!.abs().toStringAsFixed(1)} kg "
                    "${hasGainedWeight ? "gained" : "lost"}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddWeightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add Today's Weight",
              style: TextStyle(
                color: textDark,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Record your latest body weight.",
              style: TextStyle(color: textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                color: textDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: "Weight",
                hintText: "Enter today's weight",
                suffixText: "kg",
                prefixIcon: const Icon(
                  Icons.monitor_weight_outlined,
                  color: primaryDark,
                ),
                filled: true,
                fillColor: scaffoldBg,
                labelStyle: const TextStyle(color: textMuted),
                hintStyle: const TextStyle(color: Color(0xFFB6C0BA)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: primary, width: 1.6),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Weight cannot be empty";
                }

                final number = double.tryParse(value.trim());

                if (number == null) {
                  return "Enter a valid weight";
                }

                if (number <= 0) {
                  return "Weight must be greater than zero";
                }

                if (number > 500) {
                  return "Enter a realistic weight";
                }

                return null;
              },
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : saveWeight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  isSaving ? "Saving..." : "SAVE WEIGHT",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: .6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    if (isLoadingHistory) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Weight History",
          style: TextStyle(
            color: textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Track how your weight changes over time.",
          style: TextStyle(color: textMuted, fontSize: 13),
        ),
        const SizedBox(height: 18),

        if (weightHistory.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: const Column(
              children: [
                Icon(Icons.monitor_weight_outlined, size: 48, color: textMuted),
                SizedBox(height: 12),
                Text(
                  "No weight records yet",
                  style: TextStyle(color: textMuted, fontSize: 14),
                ),
              ],
            ),
          ),

        if (weightHistory.isNotEmpty)
          ...weightHistory.map((record) {
            final weight = (record["weight"] as num).toDouble();

            final date =
                record["created_at"]?.toString().split("T").first ?? "";

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.monitor_weight_outlined,
                      color: primaryDark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${weight.toStringAsFixed(1)} kg",
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Weight Entry",
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(color: textMuted, fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Saved",
                          style: TextStyle(
                            color: primaryDark,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

        const SizedBox(height: 26),

        _buildStatisticsCard(),

        const SizedBox(height: 22),

        _buildProgressInsights(),
      ],
    );
  }

  Widget _buildStatisticsCard() {
    final totalEntries = weightHistory.length;

    double? highestWeight;
    double? lowestWeight;

    if (weightHistory.isNotEmpty) {
      final values = weightHistory
          .map<double>((e) => (e["weight"] as num).toDouble())
          .toList();

      highestWeight = values.reduce((a, b) => a > b ? a : b);

      lowestWeight = values.reduce((a, b) => a < b ? a : b);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Statistics",
            style: TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _statCard("Entries", "$totalEntries", Icons.history),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  "Highest",
                  highestWeight == null
                      ? "--"
                      : "${highestWeight.toStringAsFixed(1)} kg",
                  Icons.arrow_upward,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  "Lowest",
                  lowestWeight == null
                      ? "--"
                      : "${lowestWeight.toStringAsFixed(1)} kg",
                  Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  "Current",
                  currentWeight == null
                      ? "--"
                      : "${currentWeight!.toStringAsFixed(1)} kg",
                  Icons.monitor_weight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scaffoldBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: primary.withOpacity(.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primaryDark),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textDark,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),

          const SizedBox(height: 5),

          Text(title, style: const TextStyle(color: textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProgressInsights() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: softMint,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.insights, color: primaryDark),
              ),

              const SizedBox(width: 12),

              const Text(
                "Progress Insights",
                style: TextStyle(
                  color: textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            "• Record your weight consistently.\n\n"
            "• Weigh yourself at the same time each day.\n\n"
            "• Track weekly trends instead of daily fluctuations.\n\n"
            "• Combine weight tracking with workouts and nutrition for better insights.",
            style: TextStyle(color: textMuted, fontSize: 13.5, height: 1.7),
          ),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.show_chart,
                    color: primaryDark,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Weight Progress Graph",
                  style: TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "A beautiful line chart showing your weekly and monthly weight progress will appear here.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textMuted, fontSize: 13, height: 1.5),
                ),

                const SizedBox(height: 18),

                Container(
                  height: 170,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: scaffoldBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.multiline_chart,
                          size: 52,
                          color: primaryDark,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Coming Soon",
                          style: TextStyle(
                            color: textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: softMint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_graph, color: primaryDark),
                ),

                const SizedBox(width: 14),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "More Analytics Coming",
                        style: TextStyle(
                          color: textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Future updates will include weekly averages, monthly trends, goal weight tracking, charts and AI-powered insights.",
                        style: TextStyle(color: textMuted, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
