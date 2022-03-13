import 'LeaderBoardDoc.dart';

// Model for the singleton Monthly Leaderboard document in
// the MonthlyLeaderboardEntries collection
class MonthlyLeaderboardDoc extends LeaderboardDoc {

  int? currentMonth;

  MonthlyLeaderboardDoc({id, currentSeason, prizes, this.currentMonth})
      : super(
      id: id,
      currentSeason: currentSeason,
      prizes: prizes);

}
