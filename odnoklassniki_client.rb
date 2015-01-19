#encoding: UTF-8
require 'watir-webdriver'
require 'open-uri'
require 'watir-webdriver/wait'

class OdnoklassnikiClient
  @browser
  @siteUrl

  def initialize(siteUrl = 'http://ok.ru')
    @siteUrl = siteUrl
    open_browser
  end

  def open_browser
    @browser = Watir::Browser.new :chrome # :chrome or :firefox
    @browser.goto @siteUrl
  end

  def login(user_name, password)
    @browser.goto @siteUrl

    @usr_field = @browser.text_field(:id, 'field_email')
    @pwd_field = @browser.text_field(:id, 'field_password')
    @usr_field.when_present.set(user_name)
    @pwd_field.set(password)
    @browser.input(:type, 'submit').click

    @browser.span(:id, 'portal-headline_login').wait_until_present
    return self
  end

  def profile(profile_id)
    profile_url =  get_url(profile_id)
    return OdnoklassnikiProfilePage.new(@browser, profile_url)
  end

  def close
    @browser.close
  end

  def get_url(action)
    return @siteUrl + '/' + action;
  end
end

class OdnoklassnikiProfilePage
  def initialize(browser, profileUrl)
    @browser = browser
    @profileUrl = profileUrl
  end

  def open
    @browser.goto @profileUrl
    return self
  end

  def albums
    @browser.goto get_url('albums')
    @albums = Array.new
    @browser.divs(:class, 'photo-sc_grid_i_alb-t').each { |albumDiv|
      title = albumDiv.a().title()
      url = albumDiv.a().href()
      @albums.push(OdnoklassnikiAlbumPage.new(@browser, url, title))
    }
    return @albums
  end

  def all_photos
    return OdnoklassnikiAlbumPage.new(@browser, get_url('photos'), 'Все фото')
  end

  def get_url(action)
    return @profileUrl + '/' + action;
  end
end

class OdnoklassnikiAlbumPage
  def initialize(browser, albumUrl, title)
    @browser = browser
    @albumUrl = albumUrl
    @title = title
  end

  def open
    @browser.goto @albumUrl
    return self
  end

  def show_first_photo
    first_image_in_album = @browser.img(:class, 'photo-sc_i_cnt_a_img va_target')
    first_image_in_album.when_present.click
  end

  def get_photo(i = 0)
    main_image = @browser.img(:class, 'plp_photo')
    main_image.wait_until_present

    photo_description = @browser.span(:id => 'plp_descrCntText', :class => 'plp_descrCntText').text

    return PhotoSource.new(@title, photo_description, i, main_image.src)
  end

  def move_to_next_photo
    sleep 0.2
    @browser.div(:id, 'plp_slide_r').hover
    @browser.div(:id, 'plp_slide_r').when_present.click #clicking next button
  end

  def save_to(workspace)
    show_first_photo

    first_photo = get_photo
    i=1

    loop do
      photo = get_photo(i)
      workspace.save_photo(photo)

      move_to_next_photo
      i = i + 1

      next_photo = get_photo
      break if next_photo.url === first_photo.url
    end
  end
end

class PhotoSource
  attr_accessor :album, :url, :number

  def initialize(album, description, number, url)
    @album = album
    @description = description
    @number = number
    @url = url
  end

  def name
    formatNumber = @number.to_s.rjust(3, '0')
    return "#{formatNumber} #{@description}"
  end
end

class Workspace
  def initialize(rootPath)
    @rootPath = rootPath
  end

  def prepare_album(albumName)
    albumPath = @rootPath + '\\Photos\\' + normalize(albumName)
    FileUtils.mkdir_p albumPath
    return albumPath
  end

  def normalize(path)
    return path.gsub(/[<>?:"\/\\?*\.]/, '')
               .gsub("\n", '')
               .to_s[0..255]
  end

  def save_photo(source)
    albumPath = prepare_album(source.album)
    #photoName = normalize(source.name)
    photoName = source.number.to_s.rjust(3, '0')
    File.open(albumPath + "\\" + photoName + '.jpg', 'wb') do |file|
      file.write open(source.url).read
    end
  end
end