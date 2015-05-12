class EventType
  attr_accessor :name, :title, :tag, :rank, :is_remote, :is_default, :available_options

  def get_class
    self.class
  end

  alias_method :is_remote?, :is_remote

end
