import 'package:flutter/material.dart';

class AIResultScreen extends StatelessWidget {
final String productName;
final String category;
final String description;

const AIResultScreen({
super.key,
required this.productName,
required this.category,
required this.description,
});

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFFFF8F0),


  appBar: AppBar(
    backgroundColor: const Color(0xFF8B4513),
    foregroundColor: Colors.white,
    elevation: 0,
    title: const Text(
      'AI Product Result',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),

  body: SingleChildScrollView(
    padding: const EdgeInsets.all(20),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        const Text(
          'Your AI-generated listing ✨',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D2E0C),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Review the details before saving your product.',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF6D4C41),
          ),
        ),

        const SizedBox(height: 25),

        // PRODUCT NAME
        _buildCard(
          title: 'Product Name',
          icon: Icons.inventory_2,
          child: Text(
            productName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D2E0C),
            ),
          ),
        ),

        const SizedBox(height: 15),

        // CATEGORY
        _buildCard(
          title: 'Category',
          icon: Icons.category,
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF6D4C41),
            ),
          ),
        ),

        const SizedBox(height: 15),

        // DESCRIPTION
        _buildCard(
          title: 'AI Description',
          icon: Icons.auto_awesome,
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Color(0xFF4E342E),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // PRICE CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),

          decoration: BoxDecoration(
            color: const Color(0xFFE8C39E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF8B4513),
              width: 2,
            ),
          ),

          child: Column(
            children: [
              const Icon(
                Icons.currency_rupee,
                size: 45,
                color: Color(0xFF8B4513),
              ),

              const SizedBox(height: 10),

              const Text(
                'AI Suggested Price',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D2E0C),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                '₹1,500 – ₹2,500',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Based on category, craftsmanship and market value.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6D4C41),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // SAVE BUTTON
        SizedBox(
          width: double.infinity,
          height: 55,

          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Product saved successfully! ✅',
                  ),
                ),
              );
            },

            icon: const Icon(
              Icons.save,
            ),

            label: const Text(
              'SAVE PRODUCT',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF8B4513),
              foregroundColor: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15),
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),

        // SHARE BUTTON
        SizedBox(
          width: double.infinity,
          height: 55,

          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Catalog sharing will be added next. 📤',
                  ),
                ),
              );
            },

            icon: const Icon(
              Icons.share,
            ),

            label: const Text(
              'SHARE CATALOG',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            style: OutlinedButton.styleFrom(
              foregroundColor:
                  const Color(0xFF8B4513),

              side: const BorderSide(
                color: Color(0xFF8B4513),
                width: 2,
              ),

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15),
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),
      ],
    ),
  ),
);


}

Widget _buildCard({
required String title,
required IconData icon,
required Widget child,
}) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(18),


  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),

    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 7,
        offset: Offset(0, 3),
      ),
    ],
  ),

  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,

    children: [
      Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF8B4513),
          ),

          const SizedBox(width: 10),

          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D2E0C),
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      child,
    ],
  ),
);


}
}
