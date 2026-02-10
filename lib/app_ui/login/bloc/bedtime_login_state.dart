import 'package:equatable/equatable.dart';

abstract class BedtimeLoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeLoginInitial extends BedtimeLoginState {}

class BedtimeLoginLoading extends BedtimeLoginState {}

class BedtimeLoginSuccess extends BedtimeLoginState {}

class BedtimeLoginFailure extends BedtimeLoginState {
  final String message;
  BedtimeLoginFailure(this.message);
}
