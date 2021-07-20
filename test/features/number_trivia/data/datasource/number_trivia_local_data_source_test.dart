import 'dart:convert';

import 'package:tddcourse/core/error/exceptions.dart';
import 'package:tddcourse/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tddcourse/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matcher/matcher.dart';
import 'number_trivia_local_data_source_test.mocks.dart';

import '../../../../fixtures/fixture_reader.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));

    test(
      'should return NumberTrivia from SharedPreferences when there is one in the cache',
      () async {
        // arrange
        when(mockSharedPreferences.getString(any))
            .thenReturn(fixture('trivia_cached.json'));
        // act
        final result = await dataSource.getLastNumberTrivia();
        // assert
        verify(mockSharedPreferences.getString(cachedNumberTrivia));
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a CacheExeption when there is not a cached value',
      () async {
        // arrange
        when(mockSharedPreferences.getString(any)).thenReturn(null);
        // act
        final call = dataSource.getLastNumberTrivia;
        // assert
        expect(() => call(), throwsA(const TypeMatcher<CacheException>()));
      },
    );
  });

  group('cacheNumberTrivia', () {
    const tNumberTriviaModel =
        NumberTriviaModel(number: 1, text: 'test trivia');

    test(
      'should call SharedPreferences to cache the data',
      () async {
        // arrange
        final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);
        // act
        dataSource.cacheNumberTrivia(tNumberTriviaModel);
        // assert
        verify(mockSharedPreferences.setString(
          cachedNumberTrivia,
          expectedJsonString,
        ));
      },
    );
  });
}
