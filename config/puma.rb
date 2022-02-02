workers Integer(ENV['MUMUKI_RUNNER_WORKERS'] || 0)

threads_count = Integer(ENV['MUMUKI_RUNNER_THREADS'] || 1)
threads threads_count, threads_count
