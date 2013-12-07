require 'mechanize'
require 'rubygems'
require 'net/http'
require 'pry'

# This thing sucks a bit, because I don't want to use selenium
# for clicking JS links.
# They have 3 frames, one with the missions on the upper left
# and one with a thumbnail of the image that was chosen in the
# lower frame with a table in which there are image names,
# a description and a date of the photograph and the date it was
# added to the homepage.
# I think it is good to call a mission table and collect all the
# image-names, and then use a get request to
# http://www.apolloarchive.com/apg_thumbnail-test.php?ptr=1&imageID=<IMGNAME>
# to get the frame content where I can choose to download Standard or
# sometimes high resolution images.

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
  table = {}
  resolutionlist = []
  geturls = []

  stack = {}

  # hash with the names as key, value is array of imgname
  missions.each_key do |name|
    stack[name] = []
  end

  a = Mechanize.new
  a.get(url) do |hp|

    selector = a.click(hp.frame_with(:src => "apg_selector.html").click)

    # Get all JS links from the Apollo overview
    selector.links.each do |l|
      linknames << l.href.match(/\(\'(.+)\',/)[1]
    end

    # XXX: Get rid of search and magazines link
    linknames.pop(2)

    missions.each do |name, number|
      table[name] = a.get(tableurl+number)
      table[name].links.each do |l|
        stack[name] << l.text
      end
      # XXX: Get rid of not-image-links
      stack[name].pop(6)
    end

#    stack.each do |indexnames, tables|
#      FileUtils.mkdir_p name
#      tables.each_with_index do |imgname, index|
#        geturls << dlurl + "#{index+1}" + dlurl_post + imgname
#      end
#      Dir.chdir(name) do
#        geturls.each do |l|
#          a.get(l).save
#        end
#      end
#    end

    binding.pry

    # (<count> enries found in <Name> gallery)
    # I like to use this count to verify that I got all names

    # Just to see if there are all images available that we found
    # Worst case for HighRes images: test if regex on u "*HR.jpg" returns a 200 too
    # counter = 0
    # geturls.each do |u|
    #	url = URI.parse(u)
    #	req = Net::HTTP.new(url.host, url.port)
    #	res = req.request_head(url.path)
    #	counter += 1 if res.code == "200"
    # end
  end
end
