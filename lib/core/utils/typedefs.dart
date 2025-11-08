import 'package:fpdart/fpdart.dart';
import 'package:neo_vote/core/utils/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureEitherVoid = FutureEither<void>;