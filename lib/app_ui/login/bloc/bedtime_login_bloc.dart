import 'package:bedtime_stories/app_ui/login/bloc/bedtime_auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_login_event.dart';
import 'bedtime_login_state.dart';

class BedtimeLoginBloc
    extends Bloc<BedtimeLoginEvent, BedtimeLoginState> {
  final BedtimeAuthRepository repository;

  BedtimeLoginBloc(this.repository) : super(BedtimeLoginInitial()) {
    on<BedtimeLoginRequested>(_onLogin);
  }

  Future<void> _onLogin(
    BedtimeLoginRequested event,
    Emitter<BedtimeLoginState> emit,
  ) async {
    emit(BedtimeLoginLoading());

    try {
      await repository.login(event.username, event.password);
      emit(BedtimeLoginSuccess());
    } catch (e) {
      emit(BedtimeLoginFailure(
        e.toString().replaceFirst("Exception:", "").trim(),
      ));
    }
  }
}
