module RakeHelpers
  def slugify(str)
    str.strip.downcase.gsub(/(&|&amp;)/, ' and ').gsub(/[\s\/\\]/, '-').gsub(/[^\w-]/, '').gsub(/[-]{2,}/, '-').gsub(/^-|-$/, '')
  end
end
