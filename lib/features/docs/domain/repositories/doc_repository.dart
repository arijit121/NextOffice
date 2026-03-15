import 'package:nextoffice/features/docs/domain/entities/doc_document.dart';

abstract class DocRepository {
  Future<List<DocDocument>> getDocuments();
  Future<void> saveDocument(DocDocument document);
}
