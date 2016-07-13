require 'spec_helper'

describe "Rustici Web Service API" do
  describe ScormCloud::ScormCloud.new($scorm_cloud_appid,$scorm_cloud_secret).dispatch do
    it { should respond_to(:get_destination_list) }
    it { should respond_to(:get_destination_info) }
    it { should respond_to(:create_destination).with(1).arguments }
    it { should respond_to(:update_destination).with(2).arguments }
    it { should respond_to(:delete_destination).with(1).arguments }
    it { should respond_to(:get_dispatch_list) }
    it { should respond_to(:get_dispatch_info).with(1).arguments }
    it { should respond_to(:create_dispatch).with(3).arguments }
    it { should respond_to(:update_dispatches).with(1).arguments }
    it { should respond_to(:download_dispatches).with(1).arguments }
    it { should respond_to(:delete_dispatches).with(1).arguments }
  end
end
