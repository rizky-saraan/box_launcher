import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class AppInfo extends Equatable {
  final String packageName;
  final String label;
  final Uint8List? icon;
  final bool isFavorite;

  const AppInfo({
    required this.packageName,
    required this.label,
    this.icon,
    this.isFavorite = false,
  });

  AppInfo copyWith({
    String? packageName,
    String? label,
    Uint8List? icon,
    bool? isFavorite,
  }) {
    return AppInfo(
      packageName: packageName ?? this.packageName,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [packageName, label, icon, isFavorite];
}
