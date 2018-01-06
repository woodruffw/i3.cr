require "./spec_helper"

describe I3::Connection do
  it "initializes" do
    con = I3::Connection.new
    con.should be_a(I3::Connection)
    con.close
  end

  it "has a socket path" do
    con = I3::Connection.new
    File.exists?(con.socket_path).should be_true
    con.close
  end

  describe "#command" do
    it "sends a single command" do
      I3.act do |con|
        begin
          res = con.command "sticky enable"

          res.size.should eq(1)

          res.each do |result|
            result.should be_a(I3::Message::Status)
            result.success.should be_true
            puts result.error
          end
        ensure
          con.command "sticky disable"
        end
      end
    end

    it "sends multiple commands" do
      I3.act do |con|
        res = con.command "sticky enable; sticky disable"

        res.size.should eq(2)

        res.each do |result|
          result.should be_a(I3::Message::Status)
          result.success.should be_true
        end
      end
    end

    it "reports a failed command" do
      I3.act do |con|
        res = con.command "madeupcommand"

        res.size.should eq(1)

        res.each do |result|
          result.should be_a(I3::Message::Status)
          result.success.should be_false
        end
      end
    end
  end

  describe "#workspaces" do
    it "returns an array of workspaces" do
      I3.act do |con|
        con.workspaces.should be_a(Array(I3::Message::Workspace))
      end
    end
  end

  pending "#subscribe" do
  end

  pending "#on_event" do
  end

  describe "#outputs" do
    it "returns an array of outputs" do
      I3.act do |con|
        con.outputs.should be_a(Array(I3::Message::Output))
      end
    end
  end

  describe "#tree" do
    it "returns a tree of containers" do
      I3.act do |con|
        con.tree.should be_a(I3::Message::Tree)
      end
    end
  end

  describe "#marks" do
    it "returns an array of strings" do
      I3.act do |con|
        con.marks.should be_a(Array(String))
      end
    end
  end

  describe "#bar_ids" do
    it "returns an array of strings" do
      I3.act do |con|
        con.bar_ids.should be_a(Array(String))
      end
    end
  end

  describe "#bar_config" do
    it "returns the config for a bar id" do
      I3.act do |con|
        con.bar_config(con.bar_ids.first).should be_a(I3::Message::Bar)
      end
    end
  end

  describe "#version" do
    it "returns the version of i3" do
      I3.act do |con|
        con.version.should be_a(I3::Message::Version)
      end
    end
  end

  describe "#binding_modes" do
    it "returns an array of strings" do
      I3.act do |con|
        con.binding_modes.should be_a(Array(String))
      end
    end
  end

  describe "#config" do
    it "returns the i3 config" do
      I3.act do |con|
        con.config.should be_a(I3::Message::Config)
      end
    end
  end
end
