class DayItem {
  final String label;
  final int date;
  final bool hasEvent;

  const DayItem({
    required this.label,
    required this.date,
    this.hasEvent = false,
  });
}

class PlanCard {
  final String intensity;
  final String title;
  final String? trainerImageUrl;
  final PlanCardType type;

  const PlanCard({
    required this.intensity,
    required this.title,
    this.trainerImageUrl,
    required this.type,
  });
}

enum PlanCardType { genZ_Slangs, cosmetic, social }

// Sample data
final List<DayItem> weekDays = [
  DayItem(label: 'Sun', date: 11),
  DayItem(label: 'Mon', date: 12),
  DayItem(label: 'Tue', date: 13),
  DayItem(label: 'Wed', date: 14), // selected
  DayItem(label: 'Thu', date: 15, hasEvent: true),
  DayItem(label: 'Fri', date: 16, hasEvent: true),
  DayItem(label: 'Sat', date: 17),
];

final List<PlanCard> planCards = [
  PlanCard(
    intensity: 'Trending',
    title: 'GenZ Slangs',
    type: PlanCardType.genZ_Slangs,
  ),
  PlanCard(
    intensity: 'Popular',
    title: 'Cosmetic',
    type: PlanCardType.cosmetic,
  ),
];