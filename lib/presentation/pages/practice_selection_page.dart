import 'package:first_app/presentation/widgets/modals/practice_card.dart';
import 'package:flutter/material.dart';
import 'package:first_app/presentation/pages/practice_config_page.dart';

enum PracticeType {
  flashcard,
  sentence,
  spelling,
  listening,
  matching,
  matchingDefinition,
}

class PracticeSelectionPage extends StatelessWidget {
  const PracticeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu Práctica'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Qué deseas practicar hoy?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Elige el tipo de práctica que mejor se adapte a tus necesidades',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    PracticeCard(
                      icon: Icons.style,
                      title: 'Flashcards',
                      description:
                          'Practica vocabulario con tarjetas interactivas',
                      color: Colors.blue,
                      onTap: () => _navigateToConfig(
                        context,
                        PracticeType.flashcard,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PracticeCard(
                      icon: Icons.sort,
                      title: 'Ordenar Oraciones',
                      description: 'Construye oraciones ordenando las palabras',
                      color: Colors.green,
                      onTap: () => _navigateToConfig(
                        context,
                        PracticeType.sentence,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PracticeCard(
                      icon: Icons.compare_arrows,
                      title: 'Emparejar',
                      description: 'Relaciona palabras con sus traducciones',
                      color: Colors.teal,
                      onTap: () => _navigateToConfig(
                        context,
                        PracticeType.matching,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PracticeCard(
                      icon: Icons.menu_book,
                      title: 'Emparejar-Definicion',
                      description: 'Relaciona palabras con sus definiciones',
                      color: Colors.amber,
                      onTap: () => _navigateToConfig(
                        context,
                        PracticeType.matchingDefinition,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PracticeCard(
                      icon: Icons.keyboard,
                      title: 'Spelling',
                      description:
                          'Escribe correctamente las palabras que escuchas',
                      color: Colors.orange,
                      onTap: () => _navigateToConfig(
                        context,
                        PracticeType.spelling,
                      ),
                      isComingSoon: true,
                    ),
                    const SizedBox(height: 16),
                    PracticeCard(
                      icon: Icons.headphones,
                      title: 'Listening',
                      description: 'Mejora tu comprensión auditiva',
                      color: Colors.purple,
                      onTap: () => _navigateToConfig(
                        context,
                        PracticeType.listening,
                      ),
                      isComingSoon: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToConfig(BuildContext context, PracticeType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeConfigPage(practiceType: type),
      ),
    );
  }
}
