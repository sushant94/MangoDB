class MangoDBException < StandardError

  public

  def self.NoNameError
    "Namespace not selected"
  end

  def self.NoNamespaceError
    "No such namespace defined"
  end

end

