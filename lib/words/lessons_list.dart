import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:chinese_words/models.dart';
import 'package:chinese_words/store.dart';
import 'package:chinese_words/widgets.dart';

import 'words_list.dart';
import 'quiz.dart';

class LessonsList extends StatelessWidget {
  LessonsList({Key key, this.title}) : super(key: key);

  static final avatarTextStyle =
      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Center(child: Text(title)),
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          final lessons = state.lessons;

          if (lessons.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (context, i) {
                final lesson = lessons[i];
                final tileTitle = '第${lesson.order}课';
                final tileSubtitle = lesson.title;

                return ListTile(
                    key: Key(lesson.title),
                    leading: CircleAvatar(
                        backgroundColor: Theme.of(context).accentColor,
                        child: Text(
                          lesson.order.toString(),
                          style: avatarTextStyle,
                        )),
                    title: Text(tileTitle),
                    subtitle: Text(tileSubtitle),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WordsList(
                                  title: lesson.title, lesson: lesson)));
                    });
              });
        });
  }

  Widget _buildFab(BuildContext context) {
    return FancyButton('Start Test', icon: Icons.explore, onTap: () {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text('Choose Lessons'),
                content: Container(
                  width: double.maxFinite,
                  height: 400,
                  child: StoreConnector<AppState, AppState>(
                      converter: (store) => store.state,
                      builder: (context, state) => ListView(
                          children: state.lessons
                              .map((lesson) => CheckboxListTile(
                                    title: Text(lesson.title),
                                    value: state.selectedLessons
                                        .contains(lesson.order),
                                    onChanged: (changed) {
                                      final store =
                                          StoreProvider.of<AppState>(context);

                                      if (changed) {
                                        store.dispatch(
                                            SelectLessonAction(lesson.order));
                                      } else {
                                        store.dispatch(
                                            UnselectLessonAction(lesson.order));
                                      }
                                    },
                                  ))
                              .toList())),
                ),
                actions: [
                  FlatButton(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text('START TEST'),
                    ),
                    onPressed: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) {
                                      final stateSnapshot = StoreProvider.of<AppState>(context).state;
                                      final selectedLessons = stateSnapshot.selectedLessons;
                                      final lessons = stateSnapshot.lessons;
                                      
                                      lessons.retainWhere((lesson) => selectedLessons.contains(lesson.order));
                                      final words = lessons.expand((lesson) => lesson.words).toList();
                                       
                                      return WordsQuiz(words: words);
                                    } 
                                    ));
                      },
                  )
                ]);
          });
    });
  }
}