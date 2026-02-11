import 'package:bedtime_stories/app_ui/home/model/bedtime_add_account_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimeAddAccountState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeAddAccountInitial extends BedtimeAddAccountState {}

class BedtimeAddAccountSaving extends BedtimeAddAccountState {}

class BedtimeAddAccountSaveSuccess extends BedtimeAddAccountState {
  final BedtimeAddAccountResponse response;

  BedtimeAddAccountSaveSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class BedtimeAddAccountSaveFailure extends BedtimeAddAccountState {
  final String message;

  BedtimeAddAccountSaveFailure(this.message);

  @override
  List<Object?> get props => [message];
}
