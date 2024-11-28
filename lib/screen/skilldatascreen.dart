import 'package:flutter/material.dart';
import 'package:soccer/appconstant.dart';
import 'package:soccer/screen/bottomnavbar/practicsescreen.dart';

class SkillDetailScreen extends StatelessWidget {
  final Map<String, dynamic> skillData;

  SkillDetailScreen({required this.skillData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          skillData["title"] ?? "Skill Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(124, 12, 17, 1),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            if (skillData["image"] != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.network(
                    '${AppConstant.awsBaseUrl}${skillData['image']}',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Title and Subtitle
            Text(
              skillData["title"] ?? "No Title",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(124, 12, 17, 1),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              skillData["subtitle"] ?? "No Subtitle",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Sections (Key Techniques, Drills, Mistakes to Avoid)
            if (skillData["keyTechniques"] != null)
              _buildSection(
                title: "Key Techniques",
                items: skillData["keyTechniques"],
              ),
            if (skillData["drills"] != null)
              _buildSection(
                title: "Drills",
                items: skillData["drills"],
              ),
            if (skillData["mistakesToAvoid"] != null)
              _buildSection(
                title: "Mistakes to Avoid",
                items: skillData["mistakesToAvoid"],
              ),

            const SizedBox(height: 20),

            // CTA Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PractiseScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(124, 12, 17, 1),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  skillData["cta"] ?? "Start Practicing",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(124, 12, 17, 1),
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Icon(Icons.circle, size: 8, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
