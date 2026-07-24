import 'dart:math';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/widgets/location_picker.dart';
import '../../data/prayer_location_repository.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen>
    with LocationPickerMixin<QiblaScreen> {
  @override
  Widget build(BuildContext context) {
    final location = ref.watch(prayerLocationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Qibla')),
      body: location == null
          ? LocationPickerPrompt(
              icon: Icons.explore_outlined,
              title: 'Find the Qibla direction',
              message:
                  'Use your device location, or pick a city manually. '
                  'Direction is calculated on-device — nothing is sent '
                  'anywhere.',
              locating: locating,
              onUseDeviceLocation: useDeviceLocation,
              onChooseCity: chooseCity,
            )
          : _QiblaBody(
              location: location,
              onChangeLocation: showChangeLocationSheet,
            ),
    );
  }
}

class _QiblaBody extends StatelessWidget {
  const _QiblaBody({required this.location, required this.onChangeLocation});

  final CachedLocation location;
  final VoidCallback onChangeLocation;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final qiblaBearing = Qibla(
      Coordinates(location.latitude, location.longitude),
    ).direction;
    final distanceKm =
        Geolocator.distanceBetween(
          location.latitude,
          location.longitude,
          Qibla.MAKKAH.latitude,
          Qibla.MAKKAH.longitude,
        ) /
        1000;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CachedLocationCard(location: location, onChange: onChangeLocation),
        const SizedBox(height: 32),
        Center(child: _Compass(qiblaBearing: qiblaBearing)),
        const SizedBox(height: 24),
        Center(
          child: Text(
            '${qiblaBearing.round()}° from North',
            style: textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            '${distanceKm.round()} km to the Kaaba',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Reads the device's compass heading and hands it to [_CompassFace], with
/// fallbacks for a missing sensor (web, or a device with no magnetometer)
/// and the brief gap before the first reading arrives.
class _Compass extends StatelessWidget {
  const _Compass({required this.qiblaBearing});

  final double qiblaBearing;

  @override
  Widget build(BuildContext context) {
    final events = FlutterCompass.events;
    if (events == null) {
      return const _CompassMessage(
        icon: Icons.explore_off_outlined,
        message: 'Compass is not available on this device.',
      );
    }

    return StreamBuilder<CompassEvent>(
      stream: events,
      builder: (context, snapshot) {
        final heading = snapshot.data?.heading;
        if (heading == null) {
          return const SizedBox(
            width: 260,
            height: 260,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _CompassFace(heading: heading, qiblaBearing: qiblaBearing);
      },
    );
  }
}

class _CompassMessage extends StatelessWidget {
  const _CompassMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 260,
      height: 260,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Smallest angle (0-180°) between two compass bearings.
double _angleDifference(double a, double b) {
  final diff = (a - b).abs() % 360;
  return diff > 180 ? 360 - diff : diff;
}

/// A ring with tick marks and a fixed marker at the top representing where
/// the phone itself is pointing, plus an arrow that rotates to always point
/// toward the Kaaba as the device turns. When the arrow points straight up
/// (aligned with the fixed marker), the phone is facing the Qibla.
class _CompassFace extends StatelessWidget {
  const _CompassFace({required this.heading, required this.qiblaBearing});

  final double heading;
  final double qiblaBearing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final facingQibla = _angleDifference(heading, qiblaBearing) <= 5;
    final arrowColor = facingQibla
        ? colorScheme.secondary
        : colorScheme.primary;
    final pointerTurns = (qiblaBearing - heading) / 360;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 1.5,
                  ),
                ),
              ),
              CustomPaint(
                size: const Size(260, 260),
                painter: _TickPainter(color: colorScheme.outline),
              ),
              Positioned(
                top: 6,
                child: Container(
                  width: 3,
                  height: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              AnimatedRotation(
                turns: pointerTurns,
                duration: const Duration(milliseconds: 150),
                child: Icon(Icons.navigation, size: 72, color: arrowColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          facingQibla ? 'Facing the Qibla' : 'Turn until the arrow points up',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: facingQibla
                ? colorScheme.secondary
                : colorScheme.onSurfaceVariant,
            fontWeight: facingQibla ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }
}

class _TickPainter extends CustomPainter {
  _TickPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    for (var deg = 0; deg < 360; deg += 30) {
      final angle = deg * pi / 180;
      final outer = Offset(
        center.dx + radius * sin(angle),
        center.dy - radius * cos(angle),
      );
      final inner = Offset(
        center.dx + (radius - 10) * sin(angle),
        center.dy - (radius - 10) * cos(angle),
      );
      canvas.drawLine(inner, outer, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TickPainter oldDelegate) =>
      oldDelegate.color != color;
}
