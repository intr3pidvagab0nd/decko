def store_dir
  if (mod = mod_file?)
    # generalize this to work with any mod (needs design)
    codecard = cardname.junction? ? left : self
    "#{ Cardio.gem_root}/mod/#{mod}/file/#{codecard.codename}"
  elsif id
    "#{ Card.paths['files'].existent.first }/#{id}"
  else
    tmp_store_dir
  end
end

def tmp_store_dir
  "#{ Card.paths['files'].existent.first }/#{key}"
end

def mod_file?
  if content.present? && content =~ /^:[^\/]+\/([^.]+)/
    $1
  end
end



format :file do

  view :core do |args|
    'File rendering of this card not yet supported'
  end


  view :style do |args|
    nil
  end

end
