import 'package:bedtime_stories/app_ui/home/model/bedtime_get_accounts_list_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimeGetAccountsListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeGetAccountsListInitial extends BedtimeGetAccountsListState {}

class BedtimeGetAccountsListLoading extends BedtimeGetAccountsListState {}

class BedtimeGetAccountsListLoaded extends BedtimeGetAccountsListState {
  final List<BedtimeGetAccountsList> accounts;

  BedtimeGetAccountsListLoaded(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class BedtimeGetAccountsListFailure extends BedtimeGetAccountsListState {
  final String message;

  BedtimeGetAccountsListFailure(this.message);

  @override
  List<Object?> get props => [message];
}

