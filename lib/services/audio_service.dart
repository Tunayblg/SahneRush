import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService instance = AudioService._();
  AudioService._();

  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _musicOn = true;
  bool _sfxOn = true;

  bool get musicOn => _musicOn;
  bool get sfxOn => _sfxOn;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _musicOn = prefs.getBool('music_on') ?? true;
    _sfxOn = prefs.getBool('sfx_on') ?? true;
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.setVolume(0.55);
  }

  Future<void> startBgMusic() async {
    if (!_musicOn) return;
    await _bgPlayer.play(AssetSource('audio/bg_music.wav'));
  }

  Future<void> stopBgMusic() async => _bgPlayer.stop();

  Future<void> pauseBgMusic() async => _bgPlayer.pause();

  Future<void> resumeBgMusic() async {
    if (_musicOn) await _bgPlayer.resume();
  }

  Future<void> playCorrect() async {
    if (!_sfxOn) return;
    await _sfxPlayer.play(AssetSource('audio/correct.wav'));
  }

  Future<void> playWrong() async {
    if (!_sfxOn) return;
    await _sfxPlayer.play(AssetSource('audio/wrong.wav'));
  }

  Future<void> playWin() async {
    if (!_sfxOn) return;
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('audio/win.wav'));
  }

  Future<void> toggleMusic() async {
    _musicOn = !_musicOn;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_on', _musicOn);
    if (_musicOn) {
      await _bgPlayer.play(AssetSource('audio/bg_music.wav'));
    } else {
      await _bgPlayer.pause();
    }
  }

  Future<void> toggleSfx() async {
    _sfxOn = !_sfxOn;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sfx_on', _sfxOn);
  }

  void dispose() {
    _bgPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
