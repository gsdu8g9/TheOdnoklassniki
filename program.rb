#!/usr/bin/env ruby
#encoding: UTF-8

require_relative 'odnoklassniki_client.rb'

login = 'valera.rykov'
password = 'zaq12wsx'
profile_id = 'valeriy.rykov'

require_relative 'odnoklassniki_client.rb'

login = 'sample_login'
password = 'sample_password'
profile_id = 'profile_id'

client = OdnoklassnikiClient.new
             .login(login, password)

profile_page = client.profile(profile_id).open

@workspace = Workspace.new(profile_id)

profile_page.all_photos
    .open
    .save_to(@workspace)

profile_page.albums.each { |album|
  album.open.save_to(@workspace)
}

client.close
