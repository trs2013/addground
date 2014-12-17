require_relative '../../lib/batch_jobs'
class ImportItemStatusDefault
  include Sidekiq::Worker
  include BatchJobs
  sidekiq_options queue: :worker_slow

  def perform(batch)
    ids = build_ids(batch)
    ImportItem.where(id: ids).update_all(status: ImportItem.statuses[:success])
  end

end