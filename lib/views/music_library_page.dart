import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/music_library_viewmodel.dart';

class MusicLibraryPage extends StatelessWidget {
  const MusicLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MusicLibraryViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Music'),
        actions: [
          IconButton(
            onPressed: vm.isLoading ? null : vm.scanDeviceAndSave,
            icon: const Icon(Icons.refresh),
            tooltip: 'Scan device',
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
              ? Center(child: Text(vm.error!))
              : ListView.separated(
                  itemCount: vm.tracks.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final track = vm.tracks[index];
                    return ListTile(
                      title: Text(track.title),
                      subtitle: Text(track.artist),
                      onTap: () => vm.playTrack(track, fromQueue: vm.tracks),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: vm.isLoading ? null : vm.syncFromApi,
        label: const Text('Sync Online'),
        icon: const Icon(Icons.cloud_download),
      ),
    );
  }
}
