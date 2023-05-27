import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open the database and store the reference
  final database = openDatabase(
    // Set the path to the database.
    /// Using the [join] function from the 'path' package is
    /// best practise to ensure the path is correctly constructed
    /// for each platform.
    join(await getDatabasesPath(), 'doggie_database.db'),

    /// When database is first created, create a table to store dogs
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
      );
    },

    /// Set the version. This executes the onCreate function and provides a
    /// path to perform database upgrades and downgrades.
    version: 1,
  );

  /// Function that inserts [Dog]s into the database
  Future<void> insertDog(Dog dog) async {
    /// A reference to the database.
    final db = await database;

    /// Insert the [dog] into the correct table.
    /// 'conflictAlgorithm' can be specified to use in case the same
    /// dog is inserted twice.
    ///
    /// In this case, the conflictAlgorithm is set to replace any
    /// previous data.
    await db.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// A method that retrieves all the dogs from the dogs table.
  Future<List<Dog>> dogs() async {
    /// A reference to the database.
    final db = await database;

    /// Query the table for all dogs
    final List<Map<String, dynamic>> maps = await db.query('dogs');

    /// Convert the List<Map<String, dynamic>> into a List<Dog>
    return List.generate(maps.length, (index) {
      return Dog(
        id: maps[index]['id'],
        name: maps[index]['name'],
        age: maps[index]['age'],
      );
    });
  }

  /// A method that updates data of a given [dog]
  Future<void> updateDog(Dog dog) async {
    /// A reference to the database
    final db = await database;

    /// Update the given dog
    await db.update(
      'dogs',
      dog.toMap(),
      // Ensure that the dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL Injection.
      whereArgs: [dog.id],
    );
  }

  /// A method that deletes a dog with given [id]
  Future<void> deleteDog(int id) async {
    /// A reference to the database
    final db = await database;

    /// Remove the dog from the database
    await db.delete(
      'dogs',
      // Use a 'where' clause to delete a specific dog
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL Injection
      whereArgs: [id],
    );
  }

  /// Create a Dog and add it to the dogs table
  var fido = const Dog(
    id: 0,
    name: 'Fido',
    age: 5,
  );

  await insertDog(fido);

  /// Use the [dogs] method to retrieve all dogs
  print(await dogs());

  /// Update Fido's age and save it to the database
  fido = Dog(
    id: fido.id,
    name: fido.name,
    age: fido.age + 2,
  );
  await updateDog(fido);

  /// Print the updated results
  print(await dogs());

  /// Delete fido from the database
  await deleteDog(fido.id);

  /// Print the list of dogs (empty)
  print(await dogs());
}

class Dog {
  final int id;
  final String name;
  final int age;

  const Dog({
    required this.id,
    required this.name,
    required this.age,
  });

  /// Convert a [Dog] into a Map for data input inside database
  /// The keys must correspond to the names of the columns in
  /// the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }

  /// Implement toString to make it easier to see information
  /// about each dog using the print statement.
  @override
  String toString() {
    return 'Dog{id: $id, name: $name, age: $age}';
  }
}
