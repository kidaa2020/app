import 'package:hive/hive.dart';

part 'pet_type.g.dart';

@HiveType(typeId: 11)
enum PetType {
  @HiveField(0)
  fennec,

  @HiveField(1)
  lemur,

  @HiveField(2)
  chameleon,

  @HiveField(3)
  komodo;

  String get displayName {
    switch (this) {
      case PetType.fennec:
        return 'Zorro Fennec';
      case PetType.lemur:
        return 'Lémur';
      case PetType.chameleon:
        return 'Camaleón';
      case PetType.komodo:
        return 'Dragón de Komodo';
    }
  }

  String get emoji {
    switch (this) {
      case PetType.fennec:
        return '🦊';
      case PetType.lemur:
        return '🐒';
      case PetType.chameleon:
        return '🦎';
      case PetType.komodo:
        return '🐉';
    }
  }

  String get description {
    switch (this) {
      case PetType.fennec:
        return 'Ágil y curioso, perfecto para aventureros.';
      case PetType.lemur:
        return 'Juguetón y sociable, ideal para espíritus libres.';
      case PetType.chameleon:
        return 'Adaptable y misterioso, para los más creativos.';
      case PetType.komodo:
        return 'Poderoso y valiente, para verdaderos guerreros.';
    }
  }
}
