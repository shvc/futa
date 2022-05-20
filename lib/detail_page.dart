import 'package:flutter/material.dart';
import 'package:minio/models.dart' as mmodel;

class DetailPage extends StatelessWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final obj = ModalRoute.of(context)!.settings.arguments as mmodel.Object;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Object detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('key : ${obj.key ?? ""}'),
            Text('eTag: ${obj.eTag ?? ""}'),
            Text('size: ${obj.size ?? "unknown"}'),
            Text('mtime: ${obj.lastModified}'),
            Text('owner: ${obj.owner!.displayName} ${obj.owner!.iD}'),
            Text('storageClass: ${obj.storageClass}'),
          ],
        ),
      ),
    );
  }
}
