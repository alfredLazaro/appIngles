import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/data/repositories/word_repository_impl.dart';
import 'word_list_event.dart';
import 'word_list_state.dart';

class WordListBloc extends Bloc<WordListEvent, WordListState> {
  final WordRepositoryImpl wordRepository;

  WordListBloc({required this.wordRepository}) : super(WordListInitial()) {
    // Registramos el manejador del evento
    on<LoadWordsEvent>(_onLoadWords);
  }

//no funciona por que no tengo el metodo implementado en wordRepository
  Future<void> _onLoadWords(LoadWordsEvent event, Emitter<WordListState> emit) async {
    emit(WordListLoading());
    try {
      // Usamos el repositorio que ya limpia los datos del DAO
      // Nota: Asegúrate que tu repositorio tenga este método o usa el UseCase directamente
      final maps = await wordRepository.wordDao.getAllWordsWithImages();
      final words = WordWithImageMapper.fromMapList(maps);
      
      emit(WordListLoaded(words));
    } catch (e) {
      emit(WordListError("Error al cargar palabras: ${e.toString()}"));
    }
  }
}