require 'spec_helper'

describe "Rustici Web Service API" do
  describe ScormCloud::ScormCloud.new($scorm_cloud_appid,$scorm_cloud_secret,$scorm_cloud_url).reporting do
    it { should respond_to(:get_account_info) }
    it { should respond_to(:get_reportage_auth) }
    it { should respond_to(:launch_report) }
  end
end
