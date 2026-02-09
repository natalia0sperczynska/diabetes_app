// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealAdapter extends TypeAdapter<Meal> {
  @override
  final int typeId = 0;

  @override
  Meal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Meal(
      name: fields[0] as String,
      calories: fields[1] as int,
      protein: fields[2] as double,
      fat: fields[3] as double,
      carbs: fields[4] as double,
      fiber: fields[5] as double,
      sugars: fields[6] as double,
      salt: fields[7] as double,
      grams: fields[8] as int,
      glycemicIndex: fields[9] as double?,
      imageUrl: fields[10] as String?,
      mealType: fields[11] == null ? 'Snack' : fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Meal obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.calories)
      ..writeByte(2)
      ..write(obj.protein)
      ..writeByte(3)
      ..write(obj.fat)
      ..writeByte(4)
      ..write(obj.carbs)
      ..writeByte(5)
      ..write(obj.fiber)
      ..writeByte(6)
      ..write(obj.sugars)
      ..writeByte(7)
      ..write(obj.salt)
      ..writeByte(8)
      ..write(obj.grams)
      ..writeByte(9)
      ..write(obj.glycemicIndex)
      ..writeByte(10)
      ..write(obj.imageUrl)
      ..writeByte(11)
      ..write(obj.mealType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
