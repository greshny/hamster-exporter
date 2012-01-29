require 'hamporter/command/base'

class Hamporter::Command::Google < Hamporter::Command::Base

  # google [command]
  #
  # should upload data to google docs
  #
  def index
    push
  end

  # google:from [DATE]
  #
  # upload task from certain date
  #
  def from
    puts args
    date = args.first
    @start_date = Date.parse(date) rescue nil
    push
  end

private

  def push
    load_configuration
    add_worksheet
    Hamster::DB
    facts = get_tasks
    fields = ['date', 'begin_time', 'finish_time', 'task', 'project']
    facts.each_with_index do |fact, i|
      fields.each_with_index do |field, index|
        @ws[i + Hamporter::Configuration.instance.google_start_row, index + 1] = fact.send field
      end
      display("#{fact.project} #{fact.date} importing #{fact.task} #{fact.begin_time} #{fact.finish_time}...")
      @ws.save
    end
  end

  def get_tasks
    unless @start_date
      Hamster::Fact.all
    else
      Hamster::Fact.filter(:start_time => @start_date..Date.today)
    end
  end

  def add_worksheet
    @ws = @session.spreadsheet_by_key(Hamporter::Configuration.instance.google_key).worksheets[0]
  end

  def load_configuration
    @session = GoogleSpreadsheet.login(Hamporter::Configuration.instance.google_login,
                                       Hamporter::Configuration.instance.google_password)
  end

end
