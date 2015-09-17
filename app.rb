require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require 'streamio-ffmpeg'

get "/media/:file" do 
  file = "media/#{params[:file]}"
  if File.exists?(file)
    return File.open(file)
  else
   return "error"
  end
end

post '/media' do
  File.open('media/' + params[:file][:filename], "w") do |f|
    f.write(params[:file][:tempfile].read)
  end
end

get '/' do
  videos = Dir.glob('media/*')
  filelist = []
  videos.each do |video|
    filelist.push(File.basename(video))
  end
  json filelist
end

get '/upload' do
  erb :index
end

post '/encode' do
  @filename = params[:media][:filename]
  file = params[:media][:tempfile]

  media = FFMPEG::Movie.new(file.path)
  
  options = {video_codec: params[:vcodec], frame_rate: 29.97, resolution: params[:size], video_bitrate: params[:Vbitrate],
             audio_codec: params[:acodec], audio_bitrate: params[:abitrate], audio_sample_rate: 44100,
             threads: 6,
             custom: "-strict experimental -ac 1"}
  
  outpath=File.dirname(file.path)
  outfile = "#{File.basename(params[:media][:filename],File.extname(params[:media][:filename]))}.#{params[:container]}"
  out="#{outpath}/#{outfile}"
  outtmp="#{outpath}/1-#{outfile}"
  logger.info "Transcoding #{file} to #{outtmp}"
  media.transcode(outtmp, options)
  if params[:container] == "mp4" then
    system "qt-faststart '#{outtmp}' '#{out}'"
    FileUtils.rm outtmp
  else
    FileUtils.mv outtmp, out
  end
  FileUtils.rm params[:media][:tempfile]
  send_file out, :filename => outfile
end


