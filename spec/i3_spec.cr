require "./spec_helper"

describe I3 do
  it "acts" do
    I3.act do |con|
      con.should be_a(I3::Connection)
    end
  end
end
