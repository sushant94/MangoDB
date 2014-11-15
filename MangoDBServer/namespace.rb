require_relative "exceptions.rb"
require 'json'
class Namespace
  attr_accessor :last_commit


  private

  def loadData
    @data = JSON.parse(@fd.read)
  end

  # load information from file
  # data is read from file only on the first access.
  def load
    return nil if @name.nil?
    @filePath = @base_url + "/store/#{@name}"
    return nil if !File.exists?(@filePath)
    @fd = File.open(@filePath + "/data", "r")
  end 

  public

  def initialize(name = nil)
    @name = name
    @base_url = File.expand_path('../', __FILE__)
    @data = nil
    load
  end

  def self.finalize
    @fd.close
  end

  # Read data only on first access
  #
  # @param key [String] Key to retrieve
  # @return Value stored in key
  def [](key)
    load if @fd.nil?
    loadData if @data.nil?
    @data[key]
  end

  def []=(key, value)
    load if @fd.nil?
    loadData if @data.nil?
    @data[key] = value
  end

  def commit
    fdw = File.open(@filePath + "/data", "w")
    fdw.write(JSON.dump(@data))
    fdw.close
    @last_commit = Time.now
  end

  def inspect
    @data.inspect
  end

  def keys
    @data.keys
  end

end

# @base_url = File.dirname(__FILE__)
# n = Namespace.new("xyz")
# n["hello"] = "New New string"
# puts n.inspect
# puts n.commit
# puts n.keys
