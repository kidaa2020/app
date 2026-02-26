// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetTypeAdapter extends TypeAdapter<PetType> {
  @override
  final int typeId = 11;

  @override
  PetType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PetType.fennec;
      case 1:
        return PetType.lemur;
      case 2:
        return PetType.chameleon;
      case 3:
        return PetType.komodo;
      default:
        return PetType.fennec;
    }
  }

  @override
  void write(BinaryWriter writer, PetType obj) {
    switch (obj) {
      case PetType.fennec:
        writer.writeByte(0);
        break;
      case PetType.lemur:
        writer.writeByte(1);
        break;
      case PetType.chameleon:
        writer.writeByte(2);
        break;
      case PetType.komodo:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
