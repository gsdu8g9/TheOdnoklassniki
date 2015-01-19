# TheOdnoklassniki
Simple ruby client for [ok.ru](http://ok.ru "ok.ru") (like [fb.com](http://fb.com "fb.com") but orange and in Russia only) as a response to my dad's wish to download all 1000+ photos to the disk.

As it my first expirience with ruby I asked google on the question and found almost working example from [https://github.com/MEDBEDb/save_images_ondoklassniki](https://github.com/MEDBEDb/save_images_ondoklassniki). 

I tried to rework [procedure-style client](https://github.com/MEDBEDb/saveimagesondoklassniki) based on [watir-webdriver](https://github.com/watir/watir-webdriver "watir-webdriver") to preferrable fluent style of API based on pattern PageObject. Of course, exact gem [page-object](https://github.com/cheezy/page-object "page-object") I found when finished :).

```ruby    
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

```

Don't ask why - the quality of downloaded back images is awful. It was couple of hours of fun experience with new language and looking pretty neat IDE [Rubymine](https://www.jetbrains.com/ruby/).