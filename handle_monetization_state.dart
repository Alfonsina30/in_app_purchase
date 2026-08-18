part of 'handle_monetization_cubit.dart';

class HandleMonetizationState extends Equatable {
  final UserLevelEnum userLevel;
  final RequestPurchaseStatus requestPurchaseStatus;

  const HandleMonetizationState({
    required this.userLevel,
    required this.requestPurchaseStatus,
  });

  HandleMonetizationState copyWith({
    UserLevelEnum? userLevel,
    RequestPurchaseStatus? requestPurchaseStatus,
  }) {
    return HandleMonetizationState(
      userLevel: userLevel ?? this.userLevel,
      requestPurchaseStatus:
          requestPurchaseStatus ?? this.requestPurchaseStatus,
    );
  }

  @override
  List<Object?> get props => [userLevel, requestPurchaseStatus];
}

