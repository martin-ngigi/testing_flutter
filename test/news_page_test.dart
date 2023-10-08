import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:testing_flutter/article.dart';
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

  testWidgets('Test title is displayed', (WidgetTester tester) async{
    arrangeNewsServiceReturns3Articles();
    await tester.pumpWidget(createWidgetUnderTest());/// create a mockup widget
    expect(find.text('News'), findsOneWidget); /// test whether test finds a widget with 'News' title

  });

  testWidgets('Testing indicator is displayed while waiting for articles ', (WidgetTester tester) async {
    arrangeNewsServiceReturns3ArticlesAfter2SecondsWait();
    await tester.pumpWidget(createWidgetUnderTest());/// create a mockup widget
    await tester.pump(const Duration(milliseconds: 500)); /// pump forces widget rebuild. i.e. rebuild after 0.5 sec
    // expect(find.byType(CircularProgressIndicator), findsOneWidget); /// test whether test finds a widget with 'News' title. This will work nly if we have only one CircularProgressIndicator per page
    expect(find.byKey(Key('progress-indicator')), findsOneWidget); /// test whether test finds a widget with 'News' title. This is used when we have multiple  CircularProgressIndicator per page
    await tester.pumpAndSettle(); ///pumpAndSettle waits until there are no more rebuilds are happening i.e. animations such as circular laoder
  });

  testWidgets('Test articles are displayed', (WidgetTester tester) async {
    arrangeNewsServiceReturns3Articles();
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    for(final article in articlesFromService){
      expect(find.text(article.title), findsOneWidget);
      expect(find.text(article.content), findsOneWidget);
    }
    
  });
}
