import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../domain/entities/recognition.dart';
import '../domain/repositories/recognition_settings_repository.dart';
import '../domain/usecases/recognize_audio.dart';
import 'recognition_views.dart';
import 'widgets/recognition_navigation.dart';

class RecognitionHome extends StatefulWidget {
  const RecognitionHome({
    required this.recognizeAudio,
    required this.settingsRepository,
    super.key,
  });

  final RecognizeAudio recognizeAudio;
  final RecognitionSettingsRepository settingsRepository;

  @override
  State<RecognitionHome> createState() => _RecognitionHomeState();
}

class _RecognitionHomeState extends State<RecognitionHome> {
  final _keyController = TextEditingController();
  final _recorder = AudioRecorder();
  int _tab = 0;
  int _secondsLeft = 8;
  bool _busy = false;
  bool _recording = false;
  String _apiKey = '';
  String _statusMessage = '';
  String _jobId = '';
  RecognitionOutcome? _outcome;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _loadKey() async {
    final saved = await widget.settingsRepository.loadApiKey();
    final savedTrack = await widget.settingsRepository.loadLastTrack();
    RecognitionOutcome? lastOutcome;
    if (savedTrack != null) {
      lastOutcome = RecognitionOutcome(status: 'success', tracks: [savedTrack]);
    }
    if (!mounted) return;
    setState(() {
      _apiKey = saved;
      _keyController.text = saved;
      _outcome = lastOutcome;
    });
  }

  Future<void> _saveKey() async {
    final value = _keyController.text.trim();
    await widget.settingsRepository.saveApiKey(value);
    if (!mounted) return;
    setState(() => _apiKey = value);
    _notify(
      value.isEmpty
          ? 'Clave eliminada.'
          : 'Clave guardada en este dispositivo.',
    );
  }

  Future<void> _recognizeAudio(Uint8List audio) async {
    if (_apiKey.trim().isEmpty) {
      setState(() => _tab = 1);
      _notify('Configura tu clave de shazam-api.com en Ajustes.');
      return;
    }
    setState(() {
      _busy = true;
      _outcome = null;
      _jobId = '';
      _statusMessage = 'Enviando audio para identificar...';
      _tab = 0;
    });
    try {
      final result = await widget.recognizeAudio(
        audio,
        apiKey: _apiKey,
        onSubmitted: (uuid) {
          if (mounted) {
            setState(() {
              _jobId = uuid;
              _statusMessage = 'Solicitud recibida. Esperando resultado...';
            });
          }
        },
        onPoll: () {
          if (mounted) {
            setState(() => _statusMessage = 'Analizando audio...');
          }
        },
      );
      if (!mounted) return;
      if (result.status == 'success' && result.tracks.isNotEmpty) {
        await widget.settingsRepository.saveLastTrack(result.tracks.first);
      }
      setState(() {
        _outcome = result;
        _busy = false;
        _statusMessage = switch (result.status) {
          'success' =>
            result.tracks.isEmpty
                ? 'La API no devolvio detalles de la cancion.'
                : '',
          'no_matches' => 'No se encontro una coincidencia para este audio.',
          'failed' =>
            result.error.isEmpty
                ? 'No se pudo procesar este audio.'
                : result.error,
          _ => result.error,
        };
      });
    } on RecognitionException catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _statusMessage = _friendlyError(error);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _statusMessage = error.toString();
      });
    }
  }

  String _friendlyError(RecognitionException error) {
    if (error.statusCode == 401) {
      return 'Clave invalida o ausente. Revisala en Ajustes.';
    }
    if (error.statusCode == 403) {
      return 'La cuenta no tiene saldo o esta suspendida.';
    }
    if (error.statusCode == 429) {
      return 'Limite alcanzado o cola ocupada. Espera y vuelve a probar.';
    }
    if (error.code == 'AUDIO_UNAVAILABLE') {
      return 'No se pudo procesar el audio grabado.';
    }
    if (error.code == 'CONTENT_RESTRICTED') {
      return 'El audio tiene restricciones regionales o de licencia.';
    }
    if (error.code == 'UNSUPPORTED_URL') {
      return 'El formato de audio no es compatible.';
    }
    if (error.code == 'FILE_TOO_LARGE') {
      return 'El audio supera el tamano permitido por tu plan.';
    }
    if (error.code == 'DURATION_EXCEEDED') {
      return 'El audio supera la duracion permitida por tu plan.';
    }
    return error.message;
  }

  Future<void> _recordAndRecognize() async {
    if (_apiKey.trim().isEmpty) {
      setState(() => _tab = 1);
      _notify('Configura tu clave de shazam-api.com en Ajustes.');
      return;
    }
    try {
      if (!await _recorder.hasPermission()) {
        _notify('Permite el acceso al microfono para identificar la musica.');
        return;
      }
      final chunks = <int>[];
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 44100,
          numChannels: 1,
        ),
      );
      final subscription = stream.listen(chunks.addAll);
      setState(() {
        _recording = true;
        _busy = true;
        _secondsLeft = 8;
        _statusMessage = 'Escuchando...';
        _outcome = null;
      });
      for (var second = 8; second > 0; second--) {
        await Future<void>.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        setState(() => _secondsLeft = second - 1);
      }
      await subscription.cancel();
      await _recorder.stop();
      if (!mounted) return;
      setState(() {
        _recording = false;
        _busy = false;
        _statusMessage = '';
      });
      await _recognizeAudio(_makeWav(Uint8List.fromList(chunks)));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _recording = false;
        _busy = false;
        _statusMessage = error.toString();
      });
    }
  }

  Uint8List _makeWav(Uint8List pcm) {
    final bytes = ByteData(44 + pcm.length);
    void writeText(int offset, String value) {
      for (var index = 0; index < value.length; index++) {
        bytes.setUint8(offset + index, value.codeUnitAt(index));
      }
    }

    writeText(0, 'RIFF');
    bytes.setUint32(4, 36 + pcm.length, Endian.little);
    writeText(8, 'WAVE');
    writeText(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 1, Endian.little);
    bytes.setUint32(24, 44100, Endian.little);
    bytes.setUint32(28, 88200, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    writeText(36, 'data');
    bytes.setUint32(40, pcm.length, Endian.little);
    bytes.buffer.asUint8List().setRange(44, 44 + pcm.length, pcm);
    return bytes.buffer.asUint8List();
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 960;
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              if (wide)
                RecognitionRail(
                  selected: _tab,
                  onSelect: (tab) => setState(() => _tab = tab),
                ),
              Expanded(
                child: Column(
                  children: [
                    RecognitionHeader(
                      wide: wide,
                      connected: _apiKey.isNotEmpty,
                      onSettings: () => setState(() => _tab = 1),
                    ),
                    Expanded(
                      child: _tab == 0 ? _discover(wide) : _settings(wide),
                    ),
                    if (!wide)
                      RecognitionBottomNavigation(
                        current: _tab,
                        onSelect: (tab) => setState(() => _tab = tab),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _discover(bool wide) => DiscoverView(
    wide: wide,
    busy: _busy,
    recording: _recording,
    secondsLeft: _secondsLeft,
    statusMessage: _statusMessage,
    jobId: _jobId,
    outcome: _outcome,
    onRecord: _recordAndRecognize,
  );

  Widget _settings(bool wide) => SettingsView(
    wide: wide,
    controller: _keyController,
    hasKey: _apiKey.isNotEmpty,
    onSave: _saveKey,
  );
}
