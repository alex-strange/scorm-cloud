module ScormCloud
  class Launch < ScormCloud::BaseObject
    attr_accessor :id, :completion, :satisfaction, :measure_status,
      :normalized_measure, :experienced_duration_tracked, :launch_time,
      :exit_time, :update_dt


    def self.from_response(response)
      l = Launch.new
      completion_result = response.completion_status.downcase
      #override to match old api return
      completion_result = "complete" if completion_result == "completed"
      l.set_attributes({
        "id"=>response.id,
        "completion"=>completion_result,
        "satisfaction"=>response.success_status.downcase,
        "measure_status"=>"",
        "normalized_measure"=>response.score.try(:scaled),
        "experienced_duration_tracked"=>response.total_seconds_tracked,
        "launch_time"=>response.launch_time,
        "exit_time"=>response.exit_time,
        "update_dt"=>response.last_runtime_update
      })
      l
    end

    def self.from_xml(xml)
      launch = Launch.new
      launch.set_attributes(xml.attributes)

      xml.children.each do |element|
        launch.set_attr(element.name, element.text)
      end

      launch
    end

  end
end
