import 'LeaderBoardDoc.dart';

// Model for the singleton Yearly Leaderboard document in
// the YearlyLeaderboardEntries collection
class YearlyLeaderboardDoc extends LeaderboardDoc {

  YearlyLeaderboardDoc({id, currentSeason, prizes})
      : super(
      id: id,
      currentSeason: currentSeason,
      prizes: prizes);

}
