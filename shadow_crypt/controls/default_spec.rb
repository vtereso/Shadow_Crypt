control 'ShadowCrypt-Default Password Check' do
  impact 1.0
  title 'Disallow certain default passwords'
  desc 'Calculate hashes with each salt and confirm no badDefaults in use'
  #ADD passwords here
  default_passwords=['password1', 'password2']
  describe shadow_crypt(default_passwords) do
    its('bad_users') {should eq 0}
  end
end
