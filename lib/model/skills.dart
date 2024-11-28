class DribblingTip {
  String title;
  String subtitle;
  String description;
  List<String> keyTechniques;
  List<String> drills;
  List<String> mistakesToAvoid;
  String cta;

  DribblingTip({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.keyTechniques,
    required this.drills,
    required this.mistakesToAvoid,
    required this.cta,
  });

  factory DribblingTip.fromJson(Map<String, dynamic> json) {
    return DribblingTip(
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      keyTechniques: List<String>.from(json['keyTechniques']),
      drills: List<String>.from(json['drills']),
      mistakesToAvoid: List<String>.from(json['mistakesToAvoid']),
      cta: json['cta'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'keyTechniques': keyTechniques,
      'drills': drills,
      'mistakesToAvoid': mistakesToAvoid,
      'cta': cta,
    };
  }
}

class ShootingTip {
  String title;
  String subtitle;
  String description;
  List<String> keyTechniques;
  List<String> drills;
  List<String> mistakesToAvoid;
  String cta;

  ShootingTip({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.keyTechniques,
    required this.drills,
    required this.mistakesToAvoid,
    required this.cta,
  });

  factory ShootingTip.fromJson(Map<String, dynamic> json) {
    return ShootingTip(
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      keyTechniques: List<String>.from(json['keyTechniques']),
      drills: List<String>.from(json['drills']),
      mistakesToAvoid: List<String>.from(json['mistakesToAvoid']),
      cta: json['cta'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'keyTechniques': keyTechniques,
      'drills': drills,
      'mistakesToAvoid': mistakesToAvoid,
      'cta': cta,
    };
  }
}

class FootballTips {
  List<DribblingTip> dribblingTips;
  List<ShootingTip> shootingTips;

  FootballTips({
    required this.dribblingTips,
    required this.shootingTips,
  });

  factory FootballTips.fromJson(Map<String, dynamic> json) {
    return FootballTips(
      dribblingTips: (json['dribblingTips'] as List)
          .map((item) => DribblingTip.fromJson(item))
          .toList(),
      shootingTips: (json['shootingTips'] as List)
          .map((item) => ShootingTip.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dribblingTips': dribblingTips.map((item) => item.toJson()).toList(),
      'shootingTips': shootingTips.map((item) => item.toJson()).toList(),
    };
  }
}
