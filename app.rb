require 'sinatra'
require 'sinatra/activerecord'
require 'pry'
require 'awesome_print'

# source: http://lifehacker.com/your-mac-logs-everything-you-download-heres-how-to-cle-1658394180
SQLITE_PATH_PATTERN = '~/Library/Preferences/com.apple.LaunchServices.QuarantineEvents*'

def find_sqlite3_path
  possible_path = Dir[File.expand_path(SQLITE_PATH_PATTERN)]
  possible_path.map { |path| [path, File.size(path)] }.sort_by { |path, size| -size }.first.first
end

set :database, {
  adapter: 'sqlite3',
  database: find_sqlite3_path
}

class LSQuarantineEvent < ActiveRecord::Base
  self.table_name = 'LSQuarantineEvent'

  def LSQuarantineTimeStamp
    ts = read_attribute :LSQuarantineTimeStamp
    ts && Time.at(ts.to_i)
  end
end

get '/' do
  @events = LSQuarantineEvent.all
  erb :index
end
