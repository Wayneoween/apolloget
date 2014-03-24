# Author: Marius Schuller
# MIT License, (c) 2014
#
# TODO:
# - Make it useable
# - Make it use threads
# - Make it use proxies?
# - Make mission selectable (e.g. "Only Apollo 1 please!")

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
    geturls[name] = []
  end

  a = Mechanize.new
  a.get(url) do |hp|
    selector = a.click(hp.frame_with(:src => "apg_selector.html").click)

    # Get all JS Apollo mission links from the overview frame in the upper left...
    selector.links.each do |l|
      # ... but not the search and magazines link
      unless l.href.match(/search|by_magazin/)
        linknames << l.href.match(/\(\'(.+)\',/)[1]
      end
    end

    puts "Getting mission_images!"
    missions.each do |name, folder_name|
      print "Searching for mission #{name}... "
      table[name] = a.get(tableurl+folder_name)
      table[name].links.each do |link|
        mission_images[name] << link.text
      end

      # Get rid of not-image-links
      mission_images[name].pop(6)
      unless mission_images[name].size == 0
        puts "found #{mission_images[name].size} images!"
      else
        # XXX: Nothing is found for Saturn V
        puts "nothing found!"
      end
    end

    #This is very slow (because they allow requests only every 2 secs)
    puts "Looking up deeplinks for downloading..."
    mission_images.each do |mission, image_table|
      puts mission
      # Get each images own frame from the upper right if clicked in the table
      image_table.each_with_index do |image_name, index|
        resolutionlist << dlurl + "#{index+1}" + dlurl_post + image_name
      end

      puts " #{resolutionlist.size}"

      # XXX: Reset content, otherwise it seems to get confused with old content
      a.reset

      # Get every site in resolutionlist and if it has a high res image linked, get this
      # otherwise get the standard resolution one
      # XXX: This is slow, maybe use different proxies for every request, threading
      resolutionlist.each do |single_image_frame|
        if a.get(single_image_frame).links_with(:text => "Hi-Res").any?
          geturls[mission] << a.get(single_image_frame).links_with(:text => "Hi-Res").first.href.to_s
        elsif a.get(single_image_frame).links_with(:text => "Standard").any?
          geturls[mission] << a.get(single_image_frame).links_with(:text => "Standard").first.href.to_s
        end
      end

      # Requests to the Archive are limited to one every two seconds, that I am
      # not able to fill the resolutionlist and begin downloading images from
      # it.
      # Either I have to proxy every second or third request because the
      # download itself will take some time that one request of that address
      # is allowed once more.

      # TODO: Create gallery to easily show the images (with link to the Archive?)

    end
  end
end
