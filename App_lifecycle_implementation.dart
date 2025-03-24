// In your audio_controller.dart
import 'package:flutter/widgets.dart';

class AudioController with WidgetsBindingObserver {
  static final Logger _log = Logger('AudioController');
  SoLoud? _soloud;
  SoundHandle? _musicHandle;
  AudioSource? _currentMusicSource;
  bool _wasPlayingBeforePause = false;
  
  Future<void> initialize() async {
    _soloud = SoLoud.instance;
    await _soloud!.init();
    
    // Register for lifecycle events
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    // Unregister from lifecycle events
    WidgetsBinding.instance.removeObserver(this);
    _soloud?.deinit();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App is visible and running in foreground
        _handleAppResumed();
        break;
      case AppLifecycleState.inactive:
        // App is in an inactive state (on the way to being paused or resumed)
        break;
      case AppLifecycleState.paused:
        // App is not visible, in the background
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        // App is detached (will be terminated)
        break;
      default:
        break;
    }
  }
  
  void _handleAppPaused() {
    // Store the current state when app goes to background
    if (_musicHandle != null && _soloud != null) {
      _wasPlayingBeforePause = _soloud!.getIsValidVoiceHandle(_musicHandle!);
      _log.info('Music state saved before app pause: $_wasPlayingBeforePause');
    }
  }
  
  void _handleAppResumed() {
    // Restore music when app comes back to foreground
    if (_wasPlayingBeforePause && 
        _musicHandle != null && 
        _soloud != null && 
        !_soloud!.getIsValidVoiceHandle(_musicHandle!)) {
      _log.info('Restoring music after app resume');
      _restoreMusic();
    }
  }
  
  Future<void> _restoreMusic() async {
    // Only try to restore if we have a music source
    if (_currentMusicSource != null) {
      _musicHandle = await _soloud!.play(
        _currentMusicSource!,
        volume: 0.6,
        looping: true,
        loopingStartAt: const Duration(seconds: 25, milliseconds: 43),
      );
    } else {
      // If for some reason we don't have the source saved, reload it
      startMusic();
    }
  }
  
  Future<void> startMusic() async {
    if (_musicHandle != null) {
      if (_soloud!.getIsValidVoiceHandle(_musicHandle!)) {
        _log.info('Music is already playing. Stopping first.');
        await _soloud!.stop(_musicHandle!);
      }
    }
    _log.info('Loading music');
    final musicSource = await _soloud!.loadAsset(
      'assets/music/looped-song.ogg',
      mode: LoadMode.disk,
    );
    
    // Save a reference to the current music source
    _currentMusicSource = musicSource;
    
    musicSource.allInstancesFinished.first.then((_) {
      _soloud!.disposeSource(musicSource);
      _log.info('Music source disposed');
      _musicHandle = null;
      _currentMusicSource = null;
    });

    _log.info('Playing music');
    _musicHandle = await _soloud!.play(
      musicSource,
      volume: 0.6,
      looping: true,
      loopingStartAt: const Duration(seconds: 25, milliseconds: 43),
    );
    
    _wasPlayingBeforePause = true;
  }
  
  void fadeOutMusic() {
    if (_musicHandle == null) {
      _log.info('Nothing to fade out');
      return;
    }
    const length = Duration(seconds: 5);
    _soloud!.fadeVolume(_musicHandle!, 0, length);
    _soloud!.scheduleStop(_musicHandle!, length);
    _wasPlayingBeforePause = false;
  }
  
  // Rest of your code...
}