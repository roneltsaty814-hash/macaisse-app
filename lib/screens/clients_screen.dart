import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/client.dart';
import '../services/storage_service.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _storage = StorageService();
  List<Client> _clients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final clients = await _storage.getClients();
    setState(() {
      _clients = clients;
      _loading = false;
    });
  }

  Future<void> _openForm({Client? existing}) async {
    final nomCtrl = TextEditingController(text: existing?.nom ?? '');
    final telCtrl = TextEditingController(text: existing?.telephone ?? '');
    final adrCtrl = TextEditingController(text: existing?.adresse ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Nouveau client' : 'Modifier le client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom')),
            TextField(controller: telCtrl, decoration: const InputDecoration(labelText: 'Téléphone')),
            TextField(controller: adrCtrl, decoration: const InputDecoration(labelText: 'Adresse (optionnel)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Enregistrer')),
        ],
      ),
    );

    if (result == true && nomCtrl.text.trim().isNotEmpty) {
      final client = Client(
        id: existing?.id ?? const Uuid().v4(),
        nom: nomCtrl.text.trim(),
        telephone: telCtrl.text.trim(),
        adresse: adrCtrl.text.trim().isEmpty ? null : adrCtrl.text.trim(),
      );
      await _storage.saveClient(client);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _clients.isEmpty
              ? const Center(child: Text('Aucun client. Ajoute ton premier client.'))
              : ListView.builder(
                  itemCount: _clients.length,
                  itemBuilder: (ctx, i) {
                    final c = _clients[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text(c.nom.isNotEmpty ? c.nom[0] : '?')),
                      title: Text(c.nom),
                      subtitle: Text(c.telephone),
                      onTap: () => _openForm(existing: c),
                    );
                  },
                ),
    );
  }
}
