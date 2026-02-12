import 'package:bedtime_stories/app_ui/home/model/bedtime_get_bank_list_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimeGetBankListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeGetBankListInitial extends BedtimeGetBankListState {}

class BedtimeGetBankListLoading extends BedtimeGetBankListState {}

class BedtimeGetBankListLoaded extends BedtimeGetBankListState {
  final List<BedtimeGetBankList> banks;

  BedtimeGetBankListLoaded(this.banks);

  @override
  List<Object?> get props => [banks];
}

class BedtimeGetBankListFailure extends BedtimeGetBankListState {
  final String message;

  BedtimeGetBankListFailure(this.message);

  @override
  List<Object?> get props => [message];
}
