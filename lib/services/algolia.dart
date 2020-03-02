import 'package:algolia/algolia.dart';

class AlgoliaService {
  final Algolia algolia = Algolia.init(
    applicationId: 'K2QDRTR8CM',
    apiKey: 'd09e06f1376cf1137d8e72c9bd41bece',
  );

  searchProducts(String search) async{
    AlgoliaQuery query = algolia.instance.index('products').search(search);
    AlgoliaQuerySnapshot snap = await query.getObjects();

    print("keko");
    print(snap.hits[0]);

    List<Map<String, dynamic>> hits = snap.hits.map((hit) => hit.data).toList();

    return hits;
  }
}
final AlgoliaService algoliaService = AlgoliaService();