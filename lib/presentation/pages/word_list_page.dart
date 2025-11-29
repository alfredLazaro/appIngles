import 'package:first_app/data/mappers/word_with_image.dart';
import 'package:first_app/domain/entities/word_with_image.dart';
import 'package:flutter/material.dart';
import 'package:first_app/data/datasources/local/WordDao.dart';
import 'package:first_app/presentation/widgets/ListaCards.dart';

class WordListPage extends StatefulWidget {
  const WordListPage({super.key});

  @override
  State<WordListPage> createState() => _WordListPageState();
}

class _WordListPageState extends State<WordListPage> {
  final WordDao wordDao = WordDao();
  late Future<List<WordWithImage>> _futureWords;

  @override
  void initState() {
    super.initState();
    _futureWords = _loadWords();
  }

  Future<List<WordWithImage>> _loadWords() async {
    final maps = await wordDao.getAllWordsWithImages();
    return WordWithImageMapper.fromMapList(maps);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Words"),
      ),
      body: FutureBuilder<List<WordWithImage>>(
        future: _futureWords,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No words found."));
          } else {
            return ListaCards(lswords: snapshot.data!);
          }
        },
      ),
    );
  }
}
