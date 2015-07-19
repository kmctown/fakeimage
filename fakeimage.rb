require 'sinatra'
require 'RMagick'
require 'rvg/rvg'

get '/' do
  "<h1>finitials</h1>"\
  " <p>Initials image service based on"\
  " <a href='http://github.com/xxx/fakeimage'>http://github.com/xxx/fakeimage</a>"\
  " and the relevant fork"\
  " <a href='http://github.com/kmctown/fakeimage'>http://github.com/kmctown/fakeimage</a>."
end

get '/:initials' do
  begin
    initials = (params[:initials] || "--").upcase
    width = params[:s] || 96
    height = width
    format = "png"
    color = color_convert(params[:color]) || 'grey69'
    text_color = color_convert(params[:textcolor]) || 'black'

    rvg = Magick::RVG.new(width, height).viewbox(0, 0, width, height) do |canvas|
      canvas.background_fill = color
    end

    img = rvg.draw

    img.format = format

    drawable = Magick::Draw.new
    drawable.pointsize = width / initials.length
    drawable.font = ("./HelveticaNueue-Light.ttf")
    drawable.fill = text_color
    drawable.gravity = Magick::CenterGravity
    drawable.annotate(img, 0, 0, 0, 0, "#{initials}")

    content_type "image/#{format}"
    img.to_blob

  rescue Exception => e
    "<p>Something broke.  You can try <a href='/200x200'>this simple test</a>."\
    " If this error occurs there as well, you are probably missing app"\
    " dependencies. Make sure RMagick is installed correctly. If the test works,"\
    " you are probably passing bad params in the url.</p><p>Use this thing like"\
    " http://host:port/200x300, or add color and textcolor params to decide color"\
    " .</p><p>Error is: [<code>#{e}</code>]</p>"\
    " <p>Params are:<br>Initials: #{initials}<br>Size: #{width}x#{height}</p>"
  end
end

private

def color_convert(original)
  if original
    if original.index('!') == 0
      original.tr('!', '#')
    else
      original
    end
  end
end
