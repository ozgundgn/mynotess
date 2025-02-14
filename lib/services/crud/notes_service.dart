// import 'dart:async';
// import 'package:flutter/cupertino.dart';
// import 'package:mynotes/extensions/list/filter.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' show join;
// import 'crud_exceptions.dart';

// class NotesService {
//   Database? _db;
//   DatabaseUser? _user;
//   //Create signleton NoteService Instance

//   static final NotesService _shared = NotesService._sharedInstance();

//   NotesService._sharedInstance() {
//     _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () {
//         _notesStreamController.sink.add(_notes);
//       },
//     );
//   }

//   factory NotesService() => _shared;

//   //
//   List<DatabaseNote> _notes = [];

//   Stream<List<DatabaseNote>> get allNotes =>
//       _notesStreamController.stream.filter((note) {
//         final currentUser = _user;
//         if (currentUser != null) {
//           return note.userId == currentUser.id;
//         } else {
//           throw UserShpuldBeSetBeforeReadingAllNotes();
//         }
//       });

//   late final StreamController<List<DatabaseNote>> _notesStreamController;

//   Future<DatabaseUser> getOrCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on CouldNotFoundUser {
//       final userCreated = await createUser(email: email);

//       if (setAsCurrentUser) {
//         _user = userCreated;
//       }
//       return userCreated;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> _cacheNotes() async {
//     final notes = await getAllNotes();
//     _notes = notes.toList();
//     _notesStreamController.add(_notes);
//   }

//   Future<DatabaseNote> updateNote({
//     required DatabaseNote note,
//     required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     final updateCounts = await db.update(
//       noteTable,
//       {
//         textColumn: text,
//         noteIsSync: 0,
//       },
//       where: "id=?",
//       whereArgs: [note.id],
//     );
//     if (updateCounts == 0) {
//       throw CouldNotUpdateNote();
//     } else {
//       final updatedNote = await getNote(id: note.id);
//       _notes.removeWhere((note) => note.id == updatedNote.id);
//       _notes.add(updatedNote);
//       _notesStreamController.add(_notes);
//       return updatedNote;
//     }
//   }

//   Future<Iterable<DatabaseNote>> getAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(noteTable);
//     return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
//   }

//   Future<DatabaseNote> getNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     var result = await db.query(
//       noteTable,
//       limit: 1,
//       where: 'id=?',
//       whereArgs: [id],
//     );

//     if (result.isEmpty) {
//       throw CouldNotFoundNote();
//     }
//     final note = DatabaseNote.fromRow(result.first);
//     _notes.removeWhere((not) => not.id == id);
//     _notes.add(note);
//     _notesStreamController.add(_notes);
//     return note;
//   }

//   Future<int> deleteAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final count = await db.delete(noteTable);
//     _notes = [];
//     _notesStreamController.add(_notes);
//     return count;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       noteTable,
//       where: 'id=?',
//       whereArgs: [id],
//     );
//     if (deletedCount == 0) {
//       throw CouldNotDeleteNote();
//     } else {
//       _notes.removeWhere((note) => note.id == id);
//       _notesStreamController.add(_notes);
//     }
//   }

//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
// //make sure owner exists in the database with the correct id
//     final dbUser = await getUser(email: owner.email);
//     if (dbUser != owner) {
//       throw CouldNotFoundUser();
//     }
//     const text = "";
//     //create the note
//     final noteId = await db.insert(
//       noteTable,
//       {
//         userIdColumn: owner.id,
//         textColumn: text,
//         noteIsSync: 1,
//       },
//     );

//     final note = DatabaseNote(
//       id: noteId,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );
//     _notes.add(note);
//     _notesStreamController.add(_notes);
//     return note;
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email=?',
//       whereArgs: [email.toLowerCase()],
//     );

//     if (results.isEmpty) {
//       throw CouldNotFoundUser();
//     } else {
//       return DatabaseUser.fromRow(results.first);
//     }
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email=?',
//       whereArgs: [email.toLowerCase()],
//     );

//     if (results.isNotEmpty) {
//       throw UserAlreadyExists();
//     }

//     int userId = await db.insert(userTable, {emailColumn: email.toLowerCase()});

//     return DatabaseUser(userId, email);
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       userTable,
//       where: 'email=?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (deletedCount != 1) {
//       throw CouldNotDeleteUser();
//     }
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       return db;
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }

//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {
//       //empty
//     }
//   }

//   Future<void> open() async {
//     if (_db != null) {
//       throw DatabaseAlreadyOpenException();
//     }

//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);

//       final db = await openDatabase(dbPath);
//       _db = db;

//       await db.execute(createUserTable);
//       await db.execute(createNoteTable);
//       await _cacheNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentsDirectory();
//     }
//   }
// }

// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;

//   const DatabaseUser(
//     this.id,
//     this.email,
//   );

//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;

//   @override
//   String toString() => 'Person, ID = $id, email = $email';
//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   DatabaseNote({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.isSyncedWithCloud,
//   });

//   DatabaseNote.fromRow(Map<String, Object?> map)
//       : id = map[noteIdColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud = (map[noteIsSync] as int) == 1 ? true : false;

//   @override
//   String toString() =>
//       'Note, ID= $id, userId=$userId, isSync= $isSyncedWithCloud, text=$text';

//   @override
//   int get hashCode => id.hashCode;

//   @override
//   operator ==(covariant DatabaseNote other) => id == other.id;
// }

// const dbName = 'testing.db';
// const noteTable = 'note';
// const userTable = 'user';
// const idColumn = 'id';
// const emailColumn = 'email';
// const noteIdColumn = "id";
// const userIdColumn = "user_id";
// const textColumn = "text";
// const noteIsSync = "is_synced_with_cloud";
// const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
//             "id"	INTEGER NOT NULL,
//             "email"	TEXT NOT NULL UNIQUE,
//             PRIMARY KEY("id" AUTOINCREMENT)
//           ); ''';
// const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
//             "id"	INTEGER NOT NULL,
//             "user_id"	INTEGER NOT NULL,
//             "text"	TEXT,
//             "is_synced_with_cloud"	INTEGER NOT NULL,
//             FOREIGN KEY("user_id") REFERENCES "user"("id"),
//             PRIMARY KEY("id" AUTOINCREMENT));
//       ''';
