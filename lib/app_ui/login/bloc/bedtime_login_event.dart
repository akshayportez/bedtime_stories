import 'package:equatable/equatable.dart';

abstract class BedtimeLoginEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeLoginRequested extends BedtimeLoginEvent {
  final String username;
  final String password;

  BedtimeLoginRequested(this.username, this.password);
}
