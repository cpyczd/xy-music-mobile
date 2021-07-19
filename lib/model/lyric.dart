import 'dart:convert';

/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-07-01 14:24:54
 * @LastEditTime: 2021-07-06 16:13:36
 */

class Lyric {
  final String lyric;
  Duration? startTime;
  Duration? endTime;
  double? offset;
  Lyric({
    required this.lyric,
    this.startTime,
    this.endTime,
    this.offset,
  });

  Lyric copyWith({
    String? lyric,
    Duration? startTime,
    Duration? endTime,
    double? offset,
  }) {
    return Lyric(
      lyric: lyric ?? this.lyric,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      offset: offset ?? this.offset,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lyric': lyric,
      'startTime': startTime?.inMilliseconds,
      'endTime': endTime?.inMilliseconds,
      'offset': offset,
    };
  }

  factory Lyric.fromMap(Map<String, dynamic> map) {
    return Lyric(
      lyric: map['lyric'],
      startTime: Duration(milliseconds: map['startTime']),
      endTime: Duration(milliseconds: map['endTime']),
      offset: map['offset'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Lyric.fromJson(String source) => Lyric.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Lyric(lyric: $lyric, startTime: $startTime, endTime: $endTime, offset: $offset)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Lyric &&
        other.lyric == lyric &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.offset == offset;
  }

  @override
  int get hashCode {
    return lyric.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        offset.hashCode;
  }
}

/// 格式化歌词
List<Lyric> defaultFormatLyric(String lyricStr) {
  RegExp reg = RegExp(r"^\[\d{2}");

  List<Lyric> result =
      lyricStr.split("\n").where((r) => reg.hasMatch(r)).map((s) {
    String time = s.substring(0, s.indexOf(']'));
    String lyric = s.substring(s.indexOf(']') + 1);
    time = s.substring(1, time.length - 1);
    int hourSeparatorIndex = time.indexOf(":");
    int minuteSeparatorIndex = time.indexOf(".");
    return Lyric(
      lyric: lyric,
      startTime: Duration(
        minutes: int.parse(
          time.substring(0, hourSeparatorIndex),
        ),
        seconds: int.parse(
            time.substring(hourSeparatorIndex + 1, minuteSeparatorIndex)),
        milliseconds: int.parse(time.substring(minuteSeparatorIndex + 1)),
      ),
    );
  }).toList();

  for (int i = 0; i < result.length - 1; i++) {
    result[i].endTime = result[i + 1].startTime;
  }
  result[result.length - 1].endTime = Duration(hours: 1);
  return result;
}

/// 查找歌词
int findLyricIndex(double curDuration, List<Lyric> lyrics) {
  for (int i = 0; i < lyrics.length; i++) {
    if (curDuration >= lyrics[i].startTime!.inMilliseconds &&
        curDuration <= lyrics[i].endTime!.inMilliseconds) {
      return i;
    }
  }
  return 0;
}
