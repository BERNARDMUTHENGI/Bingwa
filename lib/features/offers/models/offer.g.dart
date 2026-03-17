// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfferAdapter extends TypeAdapter<Offer> {
  @override
  final int typeId = 0;

  @override
  Offer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Offer(
      id: fields[0] as int,
      name: fields[1] as String,
      description: fields[2] as String?,
      type: fields[3] as String,
      bundleAmount: fields[4] as double,
      units: fields[5] as String,
      price: fields[6] as double,
      currency: fields[7] as String,
      discountPercentage: fields[8] as double?,
      validityDays: fields[9] as int,
      validityLabel: fields[10] as String?,
      ussdCodeTemplate: fields[11] as String,
      ussdProcessingType: fields[12] as String,
      ussdExpectedResponse: fields[13] as String?,
      ussdErrorPattern: fields[14] as String?,
      isFeatured: fields[15] as bool?,
      isRecurring: fields[16] as bool?,
      maxPurchasesPerCustomer: fields[17] as int?,
      availableFrom: fields[18] as DateTime?,
      availableUntil: fields[19] as DateTime?,
      tags: (fields[20] as List?)?.cast<String>(),
      metadata: (fields[21] as Map?)?.cast<String, dynamic>(),
      status: fields[22] as String,
      menuPath: (fields[23] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Offer obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.bundleAmount)
      ..writeByte(5)
      ..write(obj.units)
      ..writeByte(6)
      ..write(obj.price)
      ..writeByte(7)
      ..write(obj.currency)
      ..writeByte(8)
      ..write(obj.discountPercentage)
      ..writeByte(9)
      ..write(obj.validityDays)
      ..writeByte(10)
      ..write(obj.validityLabel)
      ..writeByte(11)
      ..write(obj.ussdCodeTemplate)
      ..writeByte(12)
      ..write(obj.ussdProcessingType)
      ..writeByte(13)
      ..write(obj.ussdExpectedResponse)
      ..writeByte(14)
      ..write(obj.ussdErrorPattern)
      ..writeByte(15)
      ..write(obj.isFeatured)
      ..writeByte(16)
      ..write(obj.isRecurring)
      ..writeByte(17)
      ..write(obj.maxPurchasesPerCustomer)
      ..writeByte(18)
      ..write(obj.availableFrom)
      ..writeByte(19)
      ..write(obj.availableUntil)
      ..writeByte(20)
      ..write(obj.tags)
      ..writeByte(21)
      ..write(obj.metadata)
      ..writeByte(22)
      ..write(obj.status)
      ..writeByte(23)
      ..write(obj.menuPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfferAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
