module ScormCloud
  class CourseService < BaseService
    not_implemented :properties, :update_assets,
      :get_file_structure, :delete_files

    # TODO: Handle Warnings
    def import_course(course_id, file)
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
      response = api_instance.create_upload_and_import_course_job(course_id,{file:file})
      { :token => response.result }
    end

    def get_assets(course_id)
      connection.call_raw("rustici.course.getAssets", { courseid: course_id })
    end

    def get_async_import_result(token)

      response = api_instance.get_import_job_status
      response
    end

    def exists(course_id)
      connection.call_raw("rustici.course.exists", :courseid => course_id).include?("<result>true</result>")
    end

    def get_attributes(course_id)
      xml = connection.call("rustici.course.getAttributes", :courseid => course_id)
      xml_to_attributes(xml)
    end

    def delete_course(course_id)
      connection.call("rustici.course.deleteCourse", :courseid => course_id)
      true
    end

    def get_manifest(course_id)
      connection.call_raw("rustici.course.getManifest", :courseid => course_id)
    end

    def get_course_list(options = {})
      xml = connection.call("rustici.course.getCourseList", options)
      xml.elements["/rsp/courselist"].map { |e| Course.from_xml(e) }
    end

    def preview(course_id, redirect_url)
      connection.launch_url("rustici.course.preview", :courseid => course_id, :redirecturl => redirect_url)
    end

    def update_attributes(course_id, attributes)
      xml = connection.call("rustici.course.updateAttributes", attributes.merge({:courseid => course_id}))
      xml_to_attributes(xml)
    end

    def get_metadata(course_id, scope='course')
      xml = connection.call("rustici.course.getMetadata", courseid: course_id, scope: scope)
      xml.elements['/rsp/package']
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
