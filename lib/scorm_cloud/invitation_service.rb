module ScormCloud
  class DispatchService < BaseService


    def create_invitation(course_id,is_public,attributes={})
      required = {course_id:course_id,public:is_public }
      xml = connection.call("rustici.invitation.createInvitation", attributes.merge(required))
      xml.elements['//invitationId'].text
    end


  end
end
