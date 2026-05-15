enum DownloadStatus { pending, downloading, done, failed, alreadyDownloaded }

class ExampleDownloadStatus {
  final String slug;
  final String title;
  final DownloadStatus status;

  const ExampleDownloadStatus({
    required this.slug,
    required this.title,
    required this.status,
  });

  ExampleDownloadStatus copyWith({DownloadStatus? status}) =>
      ExampleDownloadStatus(
        slug: slug,
        title: title,
        status: status ?? this.status,
      );
}

class DownloadState {
  final bool isRunning;
  final bool cancelled;
  final int total;
  final int completed;
  final int failed;
  final List<ExampleDownloadStatus> statuses;
  final Set<String> alreadyDownloadedSlugs;

  const DownloadState({
    required this.isRunning,
    required this.cancelled,
    required this.total,
    required this.completed,
    required this.failed,
    required this.statuses,
    required this.alreadyDownloadedSlugs,
  });

  factory DownloadState.initial() => const DownloadState(
        isRunning: false,
        cancelled: false,
        total: 0,
        completed: 0,
        failed: 0,
        statuses: [],
        alreadyDownloadedSlugs: {},
      );

  DownloadState copyWith({
    bool? isRunning,
    bool? cancelled,
    int? total,
    int? completed,
    int? failed,
    List<ExampleDownloadStatus>? statuses,
    Set<String>? alreadyDownloadedSlugs,
  }) =>
      DownloadState(
        isRunning: isRunning ?? this.isRunning,
        cancelled: cancelled ?? this.cancelled,
        total: total ?? this.total,
        completed: completed ?? this.completed,
        failed: failed ?? this.failed,
        statuses: statuses ?? this.statuses,
        alreadyDownloadedSlugs:
            alreadyDownloadedSlugs ?? this.alreadyDownloadedSlugs,
      );
}
