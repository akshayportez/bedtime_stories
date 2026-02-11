import 'package:equatable/equatable.dart';

abstract class BedtimeGetSectionListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeGetSectionListLoadRequested extends BedtimeGetSectionListEvent {
  final int companyId;

  BedtimeGetSectionListLoadRequested({required this.companyId});

  @override
  List<Object?> get props => [companyId];
}
