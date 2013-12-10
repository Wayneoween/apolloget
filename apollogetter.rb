require 'mechanize'
require 'rubygems'
require 'net/http'
require 'pry'

class ApolloGetter
  url = "http://www.apolloarchive.com/apollo_gallery.html"
  tableurl = "http://www.apolloarchive.com/apg_subject_index-test.php?gallery="

  # http://www.apolloarchive.com/apg_thumbnail-test.php?ptr=<img id>&imageID=<name>
  dlurl = "http://www.apolloarchive.com/apg_thumbnail-test.php?ptr="
  dlurl_post = "&imageID="

  missions = {'mg' => 'MG', 'apmisc' => 'EA', 'ap1' => '1', 'ap7' => '7',
              'ap8' => '8', 'ap9' => '9', 'ap10' => '10', 'ap11' => '11',
              'ap12' => '12', 'ap13' => '13', 'ap14' => '14',
              'ap15' => '15', 'ap16' => '16', 'ap17' => '17',
              'sv' => 'saturnv', 'pa' => 'PA'}

  linknames = []
  resolutionlist = []
  table = {}
  geturls = {}

  mission_images = {}

  # hash with the names as key, value is array of imgname
  missions.each_key do |name|
    mission_images[name] = []
  end

  a = Mechanize.new
  a.get(url) do |hp|
    selector = a.click(hp.frame_with(:src => "apg_selector.html").click)

    # Get all JS links from the Apollo overview
    selector.links.each do |l|
      # Just get the missions names
      linknames << l.href.match(/\(\'(.+)\',/)[1]
    end

    # XXX: Get rid of search and magazines link
    linknames.pop(2)

    missions.each do |name, folder_name|
      table[name] = a.get(tableurl+folder_name)
      table[name].links.each do |link|
        mission_images[name] << link.text
      end
      # XXX: Get rid of not-image-links
      mission_images[name].pop(6)
    end

    mission_images.each do |mission, image_table|
      image_table.each_with_index do |image_name, index|
        resolutionlist << dlurl + "#{index+1}" + dlurl_post + image_name
      end
      resolutionlist.each do |single_image_frame|
        a.get(single_image_frame).links.each do |link|
          if link.text == "Hi-Res"
            # do HR stuff
          else
            # do standard stuff
          end
        end
      end
    end
  end
end
