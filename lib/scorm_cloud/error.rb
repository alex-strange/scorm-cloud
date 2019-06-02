module ScormCloud
  class Error < RuntimeError
  end

  class RequestError < Error
    attr_reader :code, :msg, :url,:original_error

    def initialize(e, message)
      code = e.code
      msg = message
      url = ""
      super("Error In Scorm Cloud: Error=#{code} Message=#{msg} URL=#{url}")
      @code = code
      @msg = msg
      @url = url
      @original_error = e
    end
  end

  class TransportError < Error
    attr_reader :response

    def initialize(response)
      @response = response
      super("Transport error: #{response.inspect}")
    end
  end

  class InvalidPackageError < Error
    def initialize
      super('Not a valid SCORM package')
    end
  end
end
