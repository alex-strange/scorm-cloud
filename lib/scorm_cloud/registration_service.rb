module ScormCloud
  class RegistrationService < BaseService
    not_implemented :get_registration_list_results,
      :get_launch_info, :reset_global_objectives,
      :test_registration_post_url

    def create_registration(course_id, reg_id, first_name, last_name, learner_id, options = {})
      params = options.merge({
        :courseid => course_id,
        :regid => reg_id,
        :fname => first_name,
        :lname => last_name,
        :learnerid => learner_id
      })
      xml = connection.call("rustici.registration.createRegistration", params)
      !xml.elements["/rsp/success"].nil?
    end

    def delete_registration(reg_id)
      xml = connection.call("rustici.registration.deleteRegistration", {:regid => reg_id })
      !xml.elements["/rsp/success"].nil?
    end
    
    def get_registration_list(options = {})
      xml = connection.call("rustici.registration.getRegistrationList", options)
      xml.elements["/rsp/registrationlist"].map { |e| Registration.from_xml(e) }
    end

    def get_registration_result(reg_id, format = "course")
      raise "Illegal format argument: #{format}" unless ["course","activity","full"].include?(format)
      xml = connection.call("rustici.registration.getRegistrationResult", { :regid => reg_id, :resultsformat => format })

      xml.elements["/rsp/registrationreport"].reduce({}) do |acc, attr|
        acc[attr.name.to_sym] = attr.text
        acc
      end
    end

    def launch(reg_id, redirect_url, options = {})
      params = options.merge({
        :regid => reg_id,
        :redirecturl => redirect_url
      })
      connection.launch_url("rustici.registration.launch", params)
    end

    def get_launch_history(reg_id)
      xml = connection.call("rustici.registration.getLaunchHistory", { :regid => reg_id })
      xml.elements["/rsp/launchhistory"].map { |e| Launch.from_xml(e) }
    end

    def reset_registration(reg_id)
      xml = connection.call("rustici.registration.resetRegistration", {:regid => reg_id })
      !xml.elements["/rsp/success"].nil?
    end

    def update_learner_info(learner_id, first_name, last_name, options)
      params = options.merge({
        :fname => first_name,
        :lname => last_name,
        :learnerid => learner_id
      })
      xml = connection.call("rustici.registration.updateLearnerInfo", params)
      !xml.elements["/rsp/success"].nil?
    end

    def exists(reg_id)
      connection.call_raw("rustici.registration.exists", :regid => reg_id).include?("<result>true</result>")
    end
  end
end
