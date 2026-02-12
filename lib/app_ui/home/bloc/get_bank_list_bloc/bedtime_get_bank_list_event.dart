import 'package:equatable/equatable.dart';

abstract class BedtimeGetBankListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeGetBankListLoadRequested extends BedtimeGetBankListEvent {
  final int companyId;

  BedtimeGetBankListLoadRequested({required this.companyId});

  @override
  List<Object?> get props => [companyId];
}
