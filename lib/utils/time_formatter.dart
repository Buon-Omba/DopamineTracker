String formatTime(Map<String, int> timeComponents) {
  return '${timeComponents['days']}d : ${timeComponents['hours']}h : ${timeComponents['minutes']}m';
}
