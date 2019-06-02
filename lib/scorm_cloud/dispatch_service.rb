module ScormCloud
  class DispatchService < BaseService
    not_implemented  :get_destination_info

    def create_destination(name)
      destination_id = SecureRandom.uuid
      dest_schema = RusticiSoftwareCloudV2::DestinationSchema.new(name: name)
      dest_id_schema = RusticiSoftwareCloudV2::DestinationIdSchema.new(id: destination_id,data: dest_schema)
      list = RusticiSoftwareCloudV2::DestinationListSchema.new(destinations: [dest_id_schema])
      api_instance.create_destinations("default",list)
      return destination_id
    end

    def update_destination(destination_id, name)
      dest_schema = RusticiSoftwareCloudV2::DestinationSchema.new(name: name)
      api_instance.set_destination("default",destination_id,dest_schema)
      return true
    end

    def get_dispatch_list(page=1, dispatch_args = {})
      response = api_instance.get_dispatches("default",{})
      response.dispatches.map { |e| Dispatch.from_response(e) }
    end

    def get_dispatch_info(dispatch_id)
      response = api_instance.get_dispatch("default", dispatch_id, {})
      Dispatch.from_response(response)
    end

    def get_destination_list(page=1)
      response = api_instance.get_destinations("default",{})
      response.destinations.map { |e| Destination.from_response(e) }
    end

    def delete_destination(destination_id)
      response = api_instance.delete_destination("default", destination_id, {})
      return true
    end

    def create_dispatch(course_id, destination_id, dispatch_attrs = {})
      dispatch_id = SecureRandom.uuid
      dispatch = RusticiSoftwareCloudV2::CreateDispatchSchema.new(destinationId: destination_id,
        courseId: course_id,
        allow_new_registrations: true,
        instanced: false,
        registration_cap: dispatch_attrs[:registrationcap]||0,
        expiration_date: dispatch_attrs[:expirationdate],
        enabled: true
      )
      d_id = RusticiSoftwareCloudV2::CreateDispatchIdSchema.new(id: dispatch_id,
                                 data: dispatch)
      d_list = RusticiSoftwareCloudV2::CreateDispatchListSchema.new(dispatches: [d_id])
      response = api_instance.create_dispatches("default", d_list, {})
      return dispatch_id
    end

    def delete_dispatches(dispatch_id)

      response = api_instance.delete_dispatch("default", dispatch_id, opts = {})
      return true
    end

    def download_dispatches(dispatch_attrs = {})
      raise "Not Implemented: import_course"
      ds = Dispatch.where(dispatchable_type:"Course")
      if dispatch_attrs[:destinationid].present?
        ds = ds.where(learning_system_id:LearningSystem.find_by_scorm_id!(dispatch_attrs[:destinationid]).id)
      end
      if dispatch_attrs[:tags].present?
        regex = /bundle_(\d+)/
        bundle_ids = dispatch_attrs[:tags].scan(regex).map(&:last)
        ds = ds.where(dispatchable_id:BundleCourse.where(bundle_id:bundle_ids).pluck(:course_id))
      end
      return ds
      connection.call_raw("rustici.dispatch.downloadDispatches", dispatch_attrs)
    end

    def update_dispatches(dispatch_attrs = {})
      raise "Not Implemented: import_course"
      xml = connection.call("rustici.dispatch.updateDispatches", dispatch_attrs)
      !xml.elements["/rsp/success"].nil?
    end

    def download_dispatches_by_destination(destinationid)
      raise "Not Implemented: import_course"
      connection.call_raw("rustici.dispatch.downloadDispatches", { destinationid: destinationid })
    end

    def download_dispatches_by_course(courseid)
      raise "Not Implemented: import_course"
      connection.call_raw("rustici.dispatch.downloadDispatches", { courseid: courseid })
    end

    private
      def api_instance
        @api_instance ||= RusticiSoftwareCloudV2::DispatchApi.new
      end
  end
end
