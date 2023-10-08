/**
 * Integration test should test whole app or parts of app that needs to be integrated.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:testing_flutter/article.dart';
import 'package:testing_flutter/article_page.dart';
import 'package:testing_flutter/news_change_notifier.dart';
import 'package:testing_flutter/news_page.dart';
import 'package:testing_flutter/news_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late MockNewsService mockNewsService;

  /// runs before each and every test
  setUp(() {
    mockNewsService = MockNewsService();
  });

  final articlesFromService =  [
    Article(title: 'Test 1', content: 'Test 1 content'),
    Article(title: 'Test 2', content: 'Test 2 content'),
    Article(title: 'Test 3', content: 'Test 3 content'),
  ];

  void arrangeNewsServiceReturns3Articles(){
    when(()=> mockNewsService.getArticles()).thenAnswer((_) async =>articlesFromService,); ///ARRANGE
  }

  void arrangeNewsServiceReturns3ArticlesAfter2SecondsWait(){
    when(()=> mockNewsService.getArticles()).thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 2));
      return articlesFromService;
    },); ///ARRANGE
  }


  Widget createWidgetUnderTest(){
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: NewsPage(),
      ),
    );
  }

  ///Test whether after tapping, we are taken to another tile
  testWidgets("""
  Test tapping on the first article expect opens the article page
  where the full article content is displayed
  """, (WidgetTester tester) async {
    arrangeNewsServiceReturns3Articles();
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.tap(find.text('Test 1 content'));
    await tester.pumpAndSettle();
    expect(find.byType(NewsPage), findsNothing); /// we are no longer in NewsPage
    expect(find.byType(ArticlePage), findsOneWidget);/// should find ArticlePage
    expect(find.text('Test 1'), findsOneWidget);
    expect(find.text('Test 1 content'), findsOneWidget);

  });

}
