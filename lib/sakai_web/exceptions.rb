module SakaiWeb
  class NotAuthenticated < StandardError
  end

  class NotFound < StandardError
  end

  class AlreadyExists < StandardError
  end

  module Exceptions
    def run_and_handle_excpetions()
    end
  end
end
