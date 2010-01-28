Dir.chdir(File.dirname(__FILE__)) { (s = lambda { |f| File.exist?(f) ? require(f) : Dir.chdir("..") { s.call(f) } }).call("spec/spec_helper.rb") }

provider_class = Puppet::Type.type(:filesystem).provider(:lvm)

describe provider_class do
    before do
        @resource = stub("resource")
        @provider = provider_class.new(@resource)
    end

    describe 'when creating' do
        it "should execute the correct filesystem command" do
            @resource.expects(:[]).with(:name).returns('/dev/myvg/mylv')
            @provider.expects(:execute).with(['mkfs.ext3', '/dev/myvg/mylv'])
            @provider.create('ext3')
        end
    end

    describe "when collecting info" do
        it "should parse the output of 'df'" do
            @provider.expects(:df).returns(fixture(:df))
            info = @provider.info
            info['/dev/sda1'].should == {
                'fstype' => 'ext3',
                'size' => '19G',
                'used' => '1.8G',
                'avail' => '16G',
                'used_percentage' => '10%',
                'mounted' => '/'
            }
        end
    end
end