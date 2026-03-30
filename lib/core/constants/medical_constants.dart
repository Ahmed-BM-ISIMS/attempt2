/// Shared medical reference data used across screens.
class MedicalConstants {
  MedicalConstants._();

  static const Map<String, int> conditionToId = {
    'Heart Attack': 1,
    'Stroke': 2,
    'Dislocated Knee': 3,
    'Kidney Stones': 4,
    'Appendicitis': 5,
    'Torn ACL': 6,
    'Bowel Obstruction': 7,
    'Fracture': 8,
    'Gallstones': 9,
    'Hernia': 10,
  };

  static const Map<int, String> idToCondition = {
    1: 'Heart Attack',
    2: 'Stroke',
    3: 'Dislocated Knee',
    4: 'Kidney Stones',
    5: 'Appendicitis',
    6: 'Torn ACL',
    7: 'Bowel Obstruction',
    8: 'Fracture',
    9: 'Gallstones',
    10: 'Hernia',
  };

  // Vital sign valid ranges for form validation
  static const int minAge = 0;
  static const int maxAge = 120;
  static const int minHeartRate = 20;
  static const int maxHeartRate = 300;
  static const int minRespiratoryRate = 5;
  static const int maxRespiratoryRate = 60;
  static const int minOxygenSaturation = 50;
  static const int maxOxygenSaturation = 100;
  static const int minSystolicBp = 50;
  static const int maxSystolicBp = 250;
  static const int minDiastolicBp = 30;
  static const int maxDiastolicBp = 150;
}
