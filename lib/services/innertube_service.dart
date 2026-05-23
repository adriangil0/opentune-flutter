import 'dart:convert';
import 'package:dio/dio.dart';

/// InnerTube API client for YouTube Music
/// Replicates the innertube module from OpenTune Android
class InnerTubeService {
  static const String _baseUrl = 'https://music.youtube.com/youtubei/v1';
  static const String _apiKey = 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30';

  static const Map<String, dynamic> _clientInfo = {
    'clientName': 'WEB_REMIX',
    'clientVersion': '1.20240101.01.00',
    'hl': 'es',
    'gl': 'US',
    'userAgent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15',
  };

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'X-Goog-Api-Key': _apiKey,
    'X-Youtube-Client-Name': '67',
    'X-Youtube-Client-Version': '1.20240101.01.00',
    'Origin': 'https://music.youtube.com',
    'Referer': 'https://music.youtube.com/',
  };

  final Dio _dio;

  InnerTubeService()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          headers: _headers,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ));

  Map<String, dynamic> get _baseBody => {
        'context': {
          'client': _clientInfo,
        },
      };

  // ─── Search ────────────────────────────────────────────────────────────

  Future<SearchResult> search(String query,
      {String? filter, String? continuation}) async {
    final body = {
      ..._baseBody,
      'query': query,
      if (filter != null) 'params': filter,
      if (continuation != null) 'continuation': continuation,
    };

    final response = await _dio.post('/search?key=$_apiKey', data: body);
    return SearchResult.fromJson(response.data);
  }

  // ─── Home Feed ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getHomeFeed({String? continuation}) async {
    final body = {
      ..._baseBody,
      if (continuation != null) 'continuation': continuation,
    };

    final response = await _dio.post('/browse?key=$_apiKey',
        data: {
          ...body,
          'browseId': 'FEmusic_home',
        });
    return response.data;
  }

  // ─── Song / Video Info ─────────────────────────────────────────────────

  Future<SongInfo> getSongInfo(String videoId) async {
    final body = {
      ..._baseBody,
      'video_id': videoId,
      'playbackContext': {
        'contentPlaybackContext': {
          'signatureTimestamp': 19950,
        },
      },
    };

    final response = await _dio.post('/player?key=$_apiKey', data: body);
    return SongInfo.fromJson(response.data);
  }

  // ─── Related Songs ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getNextSongs(String videoId,
      {String? playlistId}) async {
    final body = {
      ..._baseBody,
      'videoId': videoId,
      if (playlistId != null) 'playlistId': playlistId,
      'isAudioOnly': true,
    };

    final response = await _dio.post('/next?key=$_apiKey', data: body);
    return response.data;
  }

  // ─── Playlist ──────────────────────────────────────────────────────────

  Future<PlaylistInfo> getPlaylist(String playlistId,
      {String? continuation}) async {
    final body = {
      ..._baseBody,
      'browseId': 'VL$playlistId',
      if (continuation != null) 'continuation': continuation,
    };

    final response = await _dio.post('/browse?key=$_apiKey', data: body);
    return PlaylistInfo.fromJson(response.data);
  }

  // ─── Artist ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getArtist(String channelId) async {
    final body = {
      ..._baseBody,
      'browseId': channelId,
    };

    final response = await _dio.post('/browse?key=$_apiKey', data: body);
    return response.data;
  }

  // ─── Album ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAlbum(String browseId) async {
    final body = {
      ..._baseBody,
      'browseId': browseId,
    };

    final response = await _dio.post('/browse?key=$_apiKey', data: body);
    return response.data;
  }

  // ─── Charts / Explore ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> getExplore() async {
    final body = {
      ..._baseBody,
      'browseId': 'FEmusic_explore',
    };

    final response = await _dio.post('/browse?key=$_apiKey', data: body);
    return response.data;
  }

  // ─── Lyrics ────────────────────────────────────────────────────────────

  Future<String?> getLyrics(String browseId) async {
    try {
      final body = {
        ..._baseBody,
        'browseId': browseId,
      };

      final response = await _dio.post('/browse?key=$_apiKey', data: body);
      final contents = response.data?['contents'];
      return contents?['sectionListRenderer']?['contents']?[0]
          ?['musicDescriptionShelfRenderer']?['description']?['runs']?[0]
          ?['text'];
    } catch (_) {
      return null;
    }
  }

  // ─── Trending ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTrending() async {
    final body = {
      ..._baseBody,
      'browseId': 'FEmusic_charts',
    };

    final response = await _dio.post('/browse?key=$_apiKey', data: body);
    return response.data;
  }
}

// ─── Data Models ────────────────────────────────────────────────────────────

class SongItem {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? thumbnailUrl;
  final Duration? duration;
  final bool isExplicit;

  const SongItem({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.thumbnailUrl,
    this.duration,
    this.isExplicit = false,
  });

  factory SongItem.fromJson(Map<String, dynamic> json) {
    final runs = json['flexColumns']?[0]?['musicResponsiveListItemFlexColumnRenderer']
        ?['text']?['runs'];
    final artistRuns = json['flexColumns']?[1]
        ?['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs'];

    return SongItem(
      id: json['overlay']?['musicItemThumbnailOverlayRenderer']
              ?['content']?['musicPlayButtonRenderer']?['playNavigationEndpoint']
              ?['watchEndpoint']?['videoId'] ??
          '',
      title: runs?[0]?['text'] ?? 'Unknown',
      artist: artistRuns?[0]?['text'] ?? 'Unknown Artist',
      thumbnailUrl: json['thumbnail']?['musicThumbnailRenderer']?['thumbnail']
          ?['thumbnails']?[0]?['url'],
    );
  }

  String get thumbnailHighRes {
    if (thumbnailUrl == null) return '';
    return thumbnailUrl!.replaceAll(RegExp(r'=w\d+-h\d+'), '=w500-h500');
  }
}

class SearchResult {
  final List<SongItem> songs;
  final List<Map<String, dynamic>> artists;
  final List<Map<String, dynamic>> albums;
  final String? continuation;

  const SearchResult({
    required this.songs,
    required this.artists,
    required this.albums,
    this.continuation,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    // Parse search results from InnerTube response
    final contents = json['contents']?['tabbedSearchResultsRenderer']
            ?['tabs']?[0]?['tabRenderer']?['content']
            ?['sectionListRenderer']?['contents'] ??
        [];

    final songs = <SongItem>[];

    for (final section in contents) {
      final items = section['musicShelfRenderer']?['contents'] ?? [];
      for (final item in items) {
        try {
          songs.add(SongItem.fromJson(
              item['musicResponsiveListItemRenderer'] ?? {}));
        } catch (_) {}
      }
    }

    return SearchResult(
      songs: songs,
      artists: [],
      albums: [],
    );
  }
}

class SongInfo {
  final String videoId;
  final String title;
  final String author;
  final List<StreamingFormat> formats;
  final String? thumbnailUrl;

  const SongInfo({
    required this.videoId,
    required this.title,
    required this.author,
    required this.formats,
    this.thumbnailUrl,
  });

  factory SongInfo.fromJson(Map<String, dynamic> json) {
    final details = json['videoDetails'] ?? {};
    final streamingData = json['streamingData'] ?? {};
    final formats = <StreamingFormat>[];

    for (final f in (streamingData['adaptiveFormats'] ?? [])) {
      if (f['mimeType']?.toString().contains('audio') == true) {
        formats.add(StreamingFormat.fromJson(f));
      }
    }

    // Sort by quality
    formats.sort((a, b) => b.bitrate.compareTo(a.bitrate));

    return SongInfo(
      videoId: details['videoId'] ?? '',
      title: details['title'] ?? 'Unknown',
      author: details['author'] ?? 'Unknown',
      formats: formats,
      thumbnailUrl: details['thumbnail']?['thumbnails']?.last?['url'],
    );
  }

  String? get bestAudioUrl =>
      formats.isNotEmpty ? formats.first.url : null;
}

class StreamingFormat {
  final String? url;
  final int bitrate;
  final String mimeType;
  final int? contentLength;

  const StreamingFormat({
    this.url,
    required this.bitrate,
    required this.mimeType,
    this.contentLength,
  });

  factory StreamingFormat.fromJson(Map<String, dynamic> json) {
    return StreamingFormat(
      url: json['url'],
      bitrate: json['bitrate'] ?? 0,
      mimeType: json['mimeType'] ?? '',
      contentLength: int.tryParse(json['contentLength']?.toString() ?? ''),
    );
  }
}

class PlaylistInfo {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final List<SongItem> tracks;
  final int? trackCount;

  const PlaylistInfo({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    required this.tracks,
    this.trackCount,
  });

  factory PlaylistInfo.fromJson(Map<String, dynamic> json) {
    return PlaylistInfo(
      id: '',
      title: json['header']?['musicDetailHeaderRenderer']?['title']?['runs']
              ?[0]?['text'] ??
          'Playlist',
      tracks: [],
    );
  }
}
