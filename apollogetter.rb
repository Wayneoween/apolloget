require 'mechanize'
require 'rubygems'
require "net/http"

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
#
# URL Schemes:
# Pre-Apollo:		http://www.hq.nasa.gov/office/pao/History/alsj/mercgem/mg-#{imgname}.jpg
# Early-Apollo:		http://www.hq.nasa.gov/office/pao/History/alsj/misc/apmisc-#{imgname}.jpg
# Apollo 1:			http://www.hq.nasa.gov/office/pao/History/alsj/a410/ap1-#{imgname}.jpg
# Apollo 7:			http://www.hq.nasa.gov/office/pao/History/alsj/a410/ap7-#{imgname}.jpg
# Apollo 8:			http://www.hq.nasa.gov/office/pao/History/alsj/a410/ap8-#{imgname}.jpg
# Apollo 9:			http://www.hq.nasa.gov/office/pao/History/alsj/a410/ap9-#{imgname}.jpg
# Apollo 10:		http://www.hq.nasa.gov/office/pao/History/alsj/a410/ap10-#{imgname}.jpg
# Apollo 11:		http://www.hq.nasa.gov/office/pao/History/alsj/a11/ap11-#{imgname}.jpg
# Apollo 12:		http://www.hq.nasa.gov/office/pao/History/alsj/a12/ap12-#{imgname}.jpg
# Apollo 13:		http://www.hq.nasa.gov/office/pao/History/alsj/a13/ap13-#{imgname}.jpg
# Apollo 14:		http://www.hq.nasa.gov/office/pao/History/alsj/a14/ap14-#{imgname}.jpg
# Apollo 15:		http://www.hq.nasa.gov/office/pao/History/alsj/a15/ap15-#{imgname}.jpg
# Apollo 16:		http://www.hq.nasa.gov/office/pao/History/alsj/a16/ap16-#{imgname}.jpg
# Apollo 17:		http://www.hq.nasa.gov/office/pao/History/alsj/a17/ap17-#{imgname}.jpg
#
# XXX: I tested only the first and the last image for the name, but found out, that in between
# there are images with AS16-#{imgname}.jpg, too...


class ApolloGetter
  url = "http://www.apolloarchive.com/apollo_gallery.html"
  tableurl = "http://www.apolloarchive.com/apg_subject_index-test.php?gallery="
  img_base_url = "http://www.hq.nasa.gov/office/pao/History/alsj/"

  preapollo = ['mg', 'apmisc']
  premoon = ['ap1', 'ap7', 'ap8', 'ap9', 'ap10']
  moon = ['ap11', 'ap12', 'ap13', 'ap14', 'ap15', 'ap16', 'ap17']
  postapollo = []

  linknames = []
  imgnames = []
  geturls = []

  a = Mechanize.new
  a.get(url) do |hp|
    selector = a.click(hp.frame_with(:src => "apg_selector.html").click)

    # Get all links in a
    selector.links.each do |l|
      linknames << l.href.match(/\(\'(.+)\',/)[1]
    end

    # XXX: Get rid of search and magazines link
    linknames.pop(2)

	# Get Apollo1 link table
    table = a.get(tableurl+"1")
    table.links.each do |l|
      # probably better to use the href
      # because all links have text, but
      # only image links are Javascript links?
      imgnames << l.text
    end

    # XXX: Get rid of not-img-links
    imgnames.pop(6)

    # (<count> enries found in <Name> gallery)
    # I like to use this count to verify that I got
    # all names

	# Now I have to know somehow which apollo mission I clicked on
	# Also HighRes images do end with *HR.jpg, I want these instead of
	# standard resolution.
	imgnames.each do |l|
		if l.downcase.match(/^ap\d/)
			l = l.downcase.gsub(/id/, "ID")
			geturls << img_base_url + "a410/" + "#{l}.jpg"
		else
			if l.match(/ID/)
				l = l.downcase.gsub(/id/, "ID")
			end
			geturls << img_base_url + "a410/ap1-" + "#{l}.jpg"
		end
	end

    pp table
    pp imgnames
    pp linknames
    pp geturls

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
