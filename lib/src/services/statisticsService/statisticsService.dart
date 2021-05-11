import 'package:sentry/sentry.dart';
import 'package:sketchy_coins/packages.dart';
import 'package:calc/calc.dart';

class StatisticsService {
  //Determine TimeTaken To Compute The Functions
  Future<double> queryFreqStats(String column, String term) async {
    var result;
    try {
      var input = <String>[];
      var response = await DatabaseService.client
          .from('beneficiary_accounts')
          .select(column)
          .match({column: term})
          .execute()
          .onError(
              (error, stackTrace) => throw Exception('$error $stackTrace'));

      var inputs = Frequencies.from(input);
      for (var items in response.data as List) {
        input.add(items[column]);
      }

      result = inputs.pmf('$term');
    } on PostgrestError catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: stackTrace,
      );
      rethrow;
    } catch (e) {
      print(e);
      rethrow;
    }
    return result;
  }

  Future queryStats(String term) async {
    try {
      var input = <double>[];
      var response = await DatabaseService.client
          .from('beneficiary_accounts')
          .select(term)
          .execute()
          .onError((exception, stackTrace) async {
        await Sentry.captureException(
          exception,
          stackTrace: stackTrace,
        );

        throw Exception('$exception $stackTrace');
      });

      (response.data as List).forEach(
          (element) => input.add(double.parse(element[term].toString())));

      return calculateStats(term, input);
    } on PostgrestError catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: stackTrace,
      );
      rethrow;
    } catch (e) {
      print(e);
    }
  }

  Future calculateStats(String term, List<double> input) async {
    return {
      'average_$term': input.mean().toInt(),
      'max_$term': input.max().toInt(),
      '${term}_variance': input.variance()
    };
  }
}
