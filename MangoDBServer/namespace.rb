require File.expand_path("../exceptions.rb", __FILE__)
require 'fileutils'
require 'json'

class Namespace
  attr_accessor :last_commit

  private

  def loadData
    f = @fd.read
    if f.empty?
      @data = {}
    else
      @data = JSON.parse(f)
    end
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
    load if @fd.nil?
    loadData if @data.nil?
    @data.keys
  end

  # Returns if a particular namespace exists
  # @params name [String]
  # @return [bool]
  def self.exists?(name)
    path = File.expand_path("../store/#{name}", __FILE__)
    File.exists?(path)
  end

  # Create a new namespace
  # @params name [String]
  def self.create(name)
    path = File.expand_path("../store/#{name}", __FILE__)
    FileUtils.mkdir_p(path)
    f = File.open(path+"/data", "w")
    f.close
  end

end

