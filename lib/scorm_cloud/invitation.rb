module ScormCloud
  class Invitation < ScormCloud::BaseObject
    attr_accessor :id, :course_id, :body, :subject, :url, :allow_launch, :allow_new_registrations, :public,
      :created, :create_date, :user_invitations

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
