class PlayerResult {
  final String name;
  final double time;
  final int rank;
  final String avatar;

  PlayerResult({
    required this.name,
    required this.time,
    required this.rank,
    required this.avatar,
  });

  factory PlayerResult.fromJson(Map<String, dynamic> json) {
    return PlayerResult(
      name: json['name'],
      time: (json['time'] as num).toDouble(),
      rank: json['rank'],
      avatar: json['avatar'],
    );
  }
}
