module ScormCloud
  class Course < ScormCloud::BaseObject
    attr_accessor :id, :versions, :registrations, :title, :size
    def self.from_response(response)
      c = Course.new
      c.set_attributes({
        "id"=>response.id,
        "versions"=>response.version,
        "registrations"=>response.registration_count,
        "size"=>0
      })
      c
    end
    def self.from_xml(element)
      c = Course.new
      c.set_attributes(element.attributes)
      c
    end
  end
end
