class Book < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :account

  has_many :chapters
  has_many :notes, through: :chapters
  before_create :set_permalink

  def self.find_by_permalink(permalink)
    find_by(permalink: permalink, hidden: false)
  end

  def to_param
    permalink
  end

  def path
    Pathname.new(Rails.root + "repos") + "#{github_user}/#{github_repo}"
  end

  def enqueue
    worker = case format
    when "asciidoc"
      AsciidocBookWorker
    when "markdown"
      MarkdownBookWorker
    else
      raise "Unknown format specified."
    end

    worker.perform_async(id.to_s)
  end

  def set_permalink
    self.permalink = title.parameterize
  end
end
