class PlayerResult {
  final String playerName;
  final double time;
  final bool isLate;
  final int rank;
  final bool notClicked;

  PlayerResult({
    required this.playerName,
    required this.time,
    required this.isLate,
    required this.rank,
    required this.notClicked,
  });

  factory PlayerResult.empty() {
    return PlayerResult(
      playerName: '未知玩家',
      time: 10.00000,
      isLate: true,
      rank: 999,
      notClicked: true,
    );
  }
}
