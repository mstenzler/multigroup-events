module ControllerFormatDate

  include FormatDate

  def self.included(controller)
    controller.send :helper_method, FormatDate::FUNCTIONS
  end

end

