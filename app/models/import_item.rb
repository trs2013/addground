class ImportItem < ActiveRecord::Base
  serialize :details, Hash
  belongs_to :import

  enum status: { processing: 0, success: 1, failed: 2 }

  after_commit(on: :create) do
    FeedImporter.perform_async(self.id)
  end
end
