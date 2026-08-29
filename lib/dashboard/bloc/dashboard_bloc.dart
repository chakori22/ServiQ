import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local_markerplace/dashboard/model/post_details.dart';
import 'package:local_markerplace/dashboard/model/services.dart';
import 'package:local_markerplace/dashboard/model/your_post.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({required DashboardRepository dashboardRepository})
    : _dashboardRepository = dashboardRepository,
      super(const DashboardState.initial()) {
    on<OnFetchPostDetails>(_onFetchPostDetails);
    on<OnFetchYourPostDetails>(_onFetchYourPostDetails);
    on<OnFetchServiceDetails>(_onFetchServiceDetails);
    on<OnToggleServiceSelection>(_onToggleServiceSelection);
  }

  final DashboardRepository _dashboardRepository;

  Future<void> _onFetchPostDetails(
    OnFetchPostDetails event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(postsLoading: true));
    final result = await _dashboardRepository.getPostDetails();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            errorMessage: failure.errorMessage,
            postsLoading: false,
          ),
        );
      },
      (postDetails) {
        emit(
          state.copyWith(
            errorMessage: "",
            filteredPostDetails: postDetails.sublist(0, 4),
            postDetails: postDetails,
            postsLoading: false,
          ),
        );
      },
    );
  }

  Future<void> _onFetchYourPostDetails(
    OnFetchYourPostDetails event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(yourPostsLoading: true));
    final result = await _dashboardRepository.getYourPostDetails();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            errorMessage: failure.errorMessage,
            yourPostsLoading: false,
          ),
        );
      },
      (yourPostDetails) {
        emit(
          state.copyWith(
            errorMessage: "",
            yourPostDetails: yourPostDetails,
            yourPostsLoading: false,
          ),
        );
      },
    );
  }

  Future<void> _onFetchServiceDetails(
    OnFetchServiceDetails event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(servicesLoading: true));
    final result = await _dashboardRepository.getServiceDetails();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            errorMessage: failure.errorMessage,
            servicesLoading: false,
          ),
        );
      },
      (serviceDetails) {
        emit(
          state.copyWith(
            errorMessage: "",
            serviceDetails: serviceDetails,
            filteredServiceDetails: serviceDetails.sublist(0, 5),
            servicesLoading: false,
          ),
        );
      },
    );
  }

  void _onToggleServiceSelection(
    OnToggleServiceSelection event,
    Emitter<DashboardState> emit,
  ) {
    final updatedServices = List<ServiceDetails>.from(state.serviceDetails);
    final service = updatedServices[event.index];
    final updatedService = service.copyWith(
      isSelected: !service.isSelected,
      count: ServiceDetails.defaultCount,
    );
    updatedServices[event.index] = updatedService;

    // filteredServiceDetails holds its own copies, keep it in sync by title.
    final updatedFilteredServices = state.filteredServiceDetails
        .map(
          (filteredService) => filteredService.title == service.title
              ? updatedService
              : filteredService,
        )
        .toList();

    emit(
      state.copyWith(
        serviceDetails: updatedServices,
        filteredServiceDetails: updatedFilteredServices,
      ),
    );
  }
}
