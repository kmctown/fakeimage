require 'sinatra'
require 'RMagick'
require 'rvg/rvg'

BG_COLORS = ["#67A0D6", "#BD59BA", "#F36D61", "#489FFF", "#A6975C", "#EFA65A", "#5D69AB", "#6E927B"]

get '/' do
  "<h1>defatar</h1>"\
  " <p>Default avatar image service based on"\
  " <a href='http://github.com/xxx/fakeimage'>http://github.com/xxx/fakeimage</a>"\
  " and the relevant fork"\
  " <a href='http://github.com/kmctown/fakeimage'>http://github.com/kmctown/fakeimage</a>."
end

get '/:initials' do
  begin
    cache_control :no_cache, :must_revalidate

    initials = (params[:initials] || "--").upcase
    width = params[:s] || 64
    height = width
    format = "png"
    color = get_rand_color()
    text_color = 'white'

    rvg = Magick::RVG.new(width, height).viewbox(0, 0, width, height) do |canvas|
      canvas.background_fill = color
    end

    img = rvg.draw

    img.format = format

    drawable = Magick::Draw.new
    drawable.pointsize = 24
    drawable.font = ("./Roboto-Medium.ttf")
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

def get_rand_color()
  score = rand(0..7)

  BG_COLORS[score]
end
