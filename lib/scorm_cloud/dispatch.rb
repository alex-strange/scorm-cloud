module ScormCloud
  class Dispatch < ScormCloud::BaseObject
    attr_accessor :id, :destination_id, :app_id, :course_app_id, :course_id, :enabled, :notes, :open,
      :version, :tags, :created_by, :create_date, :update_date, :registrationcap, :registrationcount,
      :instanced, :expiration_date






    def self.from_response(response)
      binding.pry
      stored_dispatch = ::Dispatch.find_by_scorm_id!(response.id)
      c = Dispatch.new
      c.set_attributes({
        "id"=>response.id,
        "destination_id"=>response.data.destination_id,
        "app_id"=>"",
        "course_app_id"=>"",
        "course_id"=>response.data.course_id,
        "enabled"=>response.data.enabled,
        "notes"=>"",
        "open"=>response.data.allowed_new_registrations,
        "version"=>1,
        "tags"=>stored_dispatch.parsed_tags,
        "created_by"=>"",
        "create_date"=>"",
        "update_date"=>"",
        "registrationcap"=>response.data.registration_cap,
        "registrationcount"=>response.data.registration_count,
        "instanced"=>response.data.instanced,
        "expiration_date"=>response.data.expiration_date,
      })
      c
    end

    def self.from_xml(element)
      d = Dispatch.new
      d.set_attributes(element.attributes)
      element.children.each do |element|
        value = element.name == 'tags' ? element.map(&:text) : element.text
        d.set_attr(element.name, value)
      end
      d
    end
  end
end
