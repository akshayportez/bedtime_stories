import 'package:equatable/equatable.dart';

abstract class BedtimeAddAccountEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeAddAccountSaveRequested extends BedtimeAddAccountEvent {
  final Map<String, dynamic> payload;

  BedtimeAddAccountSaveRequested({
    required this.payload,
  });

  @override
  List<Object?> get props => [payload];
}
