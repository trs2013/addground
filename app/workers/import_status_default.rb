require_relative '../../lib/batch_jobs'
class ImportStatusDefault
  include Sidekiq::Worker
  include BatchJobs
  sidekiq_options queue: :worker_slow

  def perform(batch)
    ids = build_ids(batch)
    Import.where(id: ids).update_all(status: Import.statuses[:success])
  end

end