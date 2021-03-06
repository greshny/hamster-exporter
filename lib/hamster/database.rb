require 'sequel'
require 'date'
require 'hamporter/helpers'
module Hamster

  extend Hamporter::Helpers

  FIELDS = %w( activity category tag start_time end_time )
  FACTS_FIELDS = %w( date begin_time finish_time task project )

  DB = Sequel.connect(Hamporter::Configuration.instance.database_path)

  class Category < Sequel::Model
  end

  class Activity < Sequel::Model
    many_to_one :category, :key => :category_id
  end

  class Tag < Sequel::Model
  end

  class Fact < Sequel::Model
    many_to_one :activity, :key => :activity_id

    def begin_time
      Hamster.format_time(self.start_time)
    end

    def finish_time
      self.end_time.nil? ? self.begin_time : Hamster.format_time(self.end_time)
    end

    def task
      self.activity.name unless self.activity.name.nil?
    end

    def date
      Hamster.format_date(self.start_time)
    end

    def project
      self.activity.category.name unless self.activity.category.nil?
    end
  end

  class Task
    def self.all
      Hamster::Fact.all
    end

    def self.filter(start_date,end_date=nil)
      end_date ||= Date.parse(Time.now.to_s) + 1
      Hamster::Fact.filter(:start_time => start_date..end_date)
    end
  end

end
