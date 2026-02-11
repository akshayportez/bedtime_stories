import 'package:bedtime_stories/app_ui/home/model/bedtime_get_tax_list_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimeGetTaxListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeGetTaxListInitial extends BedtimeGetTaxListState {}

class BedtimeGetTaxListLoading extends BedtimeGetTaxListState {}

class BedtimeGetTaxListLoaded extends BedtimeGetTaxListState {
  final List<BedtimeGetTaxList> taxes;

  BedtimeGetTaxListLoaded(this.taxes);

  @override
  List<Object?> get props => [taxes];
}

class BedtimeGetTaxListFailure extends BedtimeGetTaxListState {
  final String message;

  BedtimeGetTaxListFailure(this.message);

  @override
  List<Object?> get props => [message];
}
