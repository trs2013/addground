class ImportItem < ActiveRecord::Base

  enum status: { processing: 0, success: 1, failed: 2 }

  serialize :details, Hash
  belongs_to :import


  after_commit(on: :create) do
    FeedImporter.perform_async(self.id)
  end
end
