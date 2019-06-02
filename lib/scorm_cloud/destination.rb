module ScormCloud
  class Destination < ScormCloud::BaseObject
    attr_accessor :id, :name, :created_by,:tags,:create_date,:update_date


    def self.from_response(response)
      c = Destination.new
      c.set_attributes({
        "id"=>response.id,
        "name"=>response.data.name,
        "created_by"=>"",
        "tags"=>[],
        "create_date"=>"",
        "update_date"=>""
      })
      c
    end

    def self.from_xml(element)
      d = Destination.new
      d.set_attributes(element.attributes)
      element.children.each do |element|
        d.set_attr(element.name, element.text)
      end
      d
    end
  end
end
