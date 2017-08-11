#test needs to added (../../test/shadow_crypt)to run this profile from cookbook directly assuming path like /test/shadow_crypt in br_fluent
lib=File.expand_path('../../shadow_crypt/libraries/vendor/gems/**/lib', __FILE__)
$:.unshift(lib.to_s)
require 'pry'
binding.pry
require 'unix_crypt'
# Custom resource based on the InSpec resource DSL
class ShadowCrypt < Inspec.resource(1)
  name 'shadow_crypt'

  desc "
    Inspec resource that hashes passwords using /etc/shadow salts.
  "

  example "
    password_list=['pass1','pass2','pass3']
    describe shadow_crypt(password_list) do
      its('bad_users') { should eq 0 }
    end
  "
  attr_reader :params
  def initialize(passwords=[])
    @params={'bad_users'=>[]}
    @salts=[]
    @path='/etc/shadow'
    @content = inspec.file(@path).content
    parse_content(passwords)
  end
  #Return bad_users else 0
  #Any users returned should change their password
  def bad_users
    @params['bad_users'].empty? ? 0 : @params['bad_users']
  end

  #Extract salts and hashes from /etc/shadow
  #Params[hash]=user k,v pair (unique hashes)
  #Iterate salts and where crypted pass=hash -> add corresponding user to bad_users
  def parse_content(passwords)
    @content.each_line do |line|
      #Capture Groups in order: DefaultCapture(0)-User(1)-Hash(2)-Salt(3)
      if /([^:]*):(\$6\$(.*)\$[^:]*)/.match(line)
        @params[$2]=$1
        @salts<<$3
      end
    end
    @salts.each do |salt|
      passwords.each do |pass|
        hash=UnixCrypt::SHA512.build(pass, salt)
        @params['bad_users']<<@params[hash] if @params[hash]
      end
    end
  end

end
