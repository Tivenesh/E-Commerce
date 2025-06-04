import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference collection(String path) {
    return _firestore.collection(path);
  }

  Future<DocumentReference> addDocument(String collectionPath, Map<String, dynamic> data) {
    return _firestore.collection(collectionPath).add(data);
  }

  Future<void> updateDocument(String collectionPath, String docId, Map<String, dynamic> data) {
    return _firestore.collection(collectionPath).doc(docId).update(data);
  }

  Future<void> deleteDocument(String collectionPath, String docId) {
    return _firestore.collection(collectionPath).doc(docId).delete();
  }

  Stream<QuerySnapshot> streamCollection(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots();
  }
}
