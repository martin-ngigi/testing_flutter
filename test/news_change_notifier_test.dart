import 'package:testing_flutter/article.dart';
import 'package:testing_flutter/news_change_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testing_flutter/news_service.dart';
import 'package:mocktail/mocktail.dart';

/**
 * advantages of using Mock is that we don't need to provide the actual implementation as opposed to the BadMockNewsService which
 * we have to provide implementation.
 * This will save time.
 */
class MockNewsService extends Mock implements NewsService{}

void main(){
  late NewsChangeNotifier sut; ///sut System Under Test -> This class is under test

  late MockNewsService mockNewsService;

  /// runs before each and every test
  setUp(() {
    mockNewsService = MockNewsService();
    sut = NewsChangeNotifier(mockNewsService);
  });

  /**
   * Test freakness - Situation where tests fail due to third parties failing. i.e. in news service failing due to network errors. This might
   * cause the tests to fail. to avoid this, create news service that will mock the real data i.e. MockNewsService class or use mocktail package.
   */

  test("Initial values are correct", () {
    expect(sut.articles, []); /// at first the articles should be empty [] , then the test will pass
    expect(sut.isLoading, false); /// at first the isLoading should be false, then the test will pass
  });

  group('getArticles', () {
    final articlesFromService =  [
      Article(title: 'Test 1', content: 'Test 1 content'),
      Article(title: 'Test 2', content: 'Test 2 content'),
      Article(title: 'Test 3', content: 'Test 3 content'),
    ];

    void arrangeNewsServiceReturns3Articles(){
      when(()=> mockNewsService.getArticles()).thenAnswer((_) async =>articlesFromService,); ///ARRANGE

    }

    test('get articles using the NewService', () async{
      /// getArticles implementation
      arrangeNewsServiceReturns3Articles();
      await sut.getArticles();///ACT
      /// test whether getArticles has been called one time
      verify(() => mockNewsService.getArticles()).called(1);///ASSERT
    });


    test("""Indicates loading of data,
    sets articles to the ones from the service,
    indicates that data is nit being loaded anymore""", () async {
      arrangeNewsServiceReturns3Articles();
      final future = sut.getArticles(); /// getArticles() is future, but we can't await here simply because if we use await by the time we are checking isLoading will already be false of which shouldn't be the case thus
      /// we use await after checking whether is loading is true.
      expect(sut.isLoading, true);
      await future;
      /// check whether the articles we get are the ones we expected
      expect(sut.articles, articlesFromService);
      ///eventually check whether isLoading =false
      expect(sut.isLoading, false);
    });
  });


}

