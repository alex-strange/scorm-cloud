module ScormCloud
  class CourseService < BaseService
    not_implemented :properties, :update_assets,
      :get_file_structure, :delete_files

    # TODO: Handle Warnings
    def import_course(course_id, file)
      raise "Not Implemented: import_course"
      xml = import_course_response('importCourse', course_id, file)

      if xml.elements['//rsp/importresult'] && xml.elements['//rsp/importresult'].attributes["successful"] == "true"
        title = xml.elements['//rsp/importresult/title'].text
        { :title => title, :warnings => [] }
      else
        # Package wasn't a zip file at all
        invalid = xml.elements['//rsp/importresult'].nil?
        # Package was a zip file that wasn't a SCORM package
        invalid ||= xml.elements['//rsp/importresult/message'] && xml.elements['//rsp/importresult/message'].text == 'zip file contained no courses'

        if invalid
          raise InvalidPackageError
        else
          xml_text = ''
          xml.write(xml_text)
          raise "Not successful. Response: #{xml_text}"
        end
      end
    end

    def import_course_async(course_id, file)
      response = api_instance.create_upload_and_import_course_job("default",course_id,{file:file})
      { :token => response.result }
    end

    def get_assets(course_id)
      raise "Not Implemented: get_assets"
      #connection.call_raw("rustici.course.getAssets", { courseid: course_id })
    end

    def get_async_import_result(token)
      response = api_instance.get_import_job_status("default",token,{may_create_new_version:true}).to_hash
      response[:status] = response[:status].downcase
      response[:status] = "finished" if response[:status]=="complete"
      response[:title] = response.dig :importResult,:course,:title
      return response
    end

    def exists(course_id)
      begin
        api_instance.get_course("default",course_id)
        return true
      rescue RusticiSoftwareCloudV2::ApiError => e
        return false
      end
    end

    def get_attributes(course_id)
      raise "Not Implemented: get_attributes"
    end

    def delete_course(course_id)
      response = api_instance.delete_course("default",course_id)
      true
    end

    def get_manifest(course_id)
      raise "Not Implemented: get_manifest"
      connection.call_raw("rustici.course.getManifest", :courseid => course_id)
    end

    def get_course_list(options = {})
      response = api_instance.get_courses("default",{include_registration_count:true})
      response.courses.map { |e| Course.from_response(e) }
    end

    def preview(course_id, redirect_url)
      launch_link_request = RusticiSoftwareCloudV2::LaunchLinkRequestSchema.new
      launch_link_request.redirect_on_exit_url = redirect_url
      response = api_instance.build_course_preview_launch_link("default",course_id, launch_link_request)
      return "#{api_instance.api_client.config.scheme}://#{api_instance.api_client.config.host}#{response.launch_link}"
    end

    def update_attributes(course_id, attributes)
      raise "Not Implemented: update_attributes"
      #xml = connection.call("rustici.course.updateAttributes", attributes.merge({:courseid => course_id}))
      #xml_to_attributes(xml)
    end

    def get_metadata(course_id, scope='course')
      api_instance.get_course("default",course_id,{include_course_metadata:true}).to_hash
      #xml = connection.call("rustici.course.getMetadata", courseid: course_id, scope: scope)
      #xml.elements['/rsp/package']
    end

    private
    def api_instance
      @api_instance ||= RusticiSoftwareCloudV2::CourseApi.new
    end
    def import_course_response(import_method, course_id, file)
      import_service = "rustici.course.#{ import_method }"

      if file.respond_to? :read
        connection.post(import_service, file, :courseid => course_id)
      else
        connection.call(import_service, :courseid => course_id, :path => file)
      end
    end
  end
end
