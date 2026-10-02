import 'package:flutter/material.dart';

/// Google Play Compliance: In-app prominent disclosure dialog explaining location usage
/// displayed prior to triggering Android system runtime permission prompts.
class LocationPermissionDisclosureDialog extends StatelessWidget {
  final bool isHindi;
  final VoidCallback onAccepted;
  final VoidCallback onDeclined;

  const LocationPermissionDisclosureDialog({
    super.key,
    this.isHindi = false,
    required this.onAccepted,
    required this.onDeclined,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF121824),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: Color(0xFFFF6B00), size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isHindi ? 'स्थान अनुमति का विवरण' : 'Location Data Disclosure',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isHindi
                  ? 'Sankalp आपके दौड़ने, टहलने या साइकिल चलाने की सटीक दूरी, गति (Pace) और रूट मैप रिकॉर्ड करने के लिए स्थान डेटा (Location Data) एकत्र करता है।'
                  : 'Sankalp collects location data to measure accurate distance, real-time pace, and map your route during active running, walking, or cycling workouts.',
              style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2234),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bulletPoint(
                    isHindi
                        ? 'यह सेवा केवल तब सक्रिय रहती है जब आप स्वयं "Start Workout" दबाते हैं।'
                        : 'Active ONLY when you explicitly start a workout.',
                  ),
                  const SizedBox(height: 8),
                  _bulletPoint(
                    isHindi
                        ? 'एक दृश्यमान नोटिफिकेशन (Ongoing Notification) स्क्रीन पर हमेशा दिखता रहेगा।'
                        : 'A prominent notification remains visible on your screen while tracking.',
                  ),
                  const SizedBox(height: 8),
                  _bulletPoint(
                    isHindi
                        ? 'कसरत बंद होने के बाद कोई भी बैकग्राउंड डेटा एकत्र नहीं किया जाता है।'
                        : 'No location data is tracked in the background once you stop or finish.',
                  ),
                  const SizedBox(height: 8),
                  _bulletPoint(
                    isHindi
                        ? 'आपका जीपीएस रूट पूरी तरह निजी है और किसी तीसरे पक्ष के साथ साझा नहीं किया जाता।'
                        : 'Your route is 100% private and never shared with third parties.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onDeclined,
          child: Text(
            isHindi ? 'अस्वीकार करें' : 'Not Now',
            style: const TextStyle(color: Color(0xFF94A3B8)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B00),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: onAccepted,
          child: Text(
            isHindi ? 'स्वीकार करें और जारी रखें' : 'I Agree & Continue',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _bulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(color: Color(0xFFFF6B00), fontSize: 16)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
        ),
      ],
    );
  }
}
