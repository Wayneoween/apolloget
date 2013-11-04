require 'mechanize'
require 'rubygems'

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

  # This is context sensitive!
  # ptr is the image number of the album
  # imageID is the name, but is irrellavant and not always
  # the real file name!
  imgpreurl = "http://www.apolloarchive.com/apg_thumbnail-test.php?ptr="

  linknames = []
  imgnames = []
  a = Mechanize.new
  a.get(url) do |hp|
    selector = a.click(hp.frame_with(:src => "apg_selector.html").click)

    # Get all links in a
    selector.links.each do |l|
      linknames << l.href.match(/\(\'(.+)\',/)[1]
    end

    # XXX: Get rid of search and magazines link
    linknames.pop(2)

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

    pp table
    pp imgnames
    pp linknames
  end
end
