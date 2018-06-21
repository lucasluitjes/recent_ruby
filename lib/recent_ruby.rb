require 'recent_ruby/version'
require 'recent_ruby/xml_ast'

module RecentRuby
  def http_get(url)
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port,
                    use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri
      response = http.request request
      if response.code != '200'
        puts "Error: received HTTP #{response.code} response from Github:\n\n#{response.body}"
        exit(2)
      end
      response.body
    end
  end

  def validate_args(gemfile, version)
    if gemfile && version
      puts 'Please supply only one argument. Run with -h for more information.'
      exit(1)
    elsif !gemfile && !version
      puts 'Please supply either a gemfile path or a version string. Run with -h for more information.'
      exit(1)
    end
  end

  def parse_gemfile(gemfile)
    ast = Parser::CurrentRuby.parse(File.read(gemfile))
    xml = RecentRuby::XMLAST.new(ast)
    version = xml.xpath("//send[symbol-val[@value='ruby']]/str/string-val/@value") || [nil]
    version = version.first ? version.first.value : nil
    unless version
      puts 'Unable to find ruby version in gemfile.'
      exit(1)
    end
    version
  end

  def validate_mri_version(version)
    return if version =~ /^(\d+\.\d+\.\d+(-p\d+)?)$/
	  puts 'Only stable release MRI version strings are currently supported. (e.g. 2.3.1 or 2.3.1-p12)'
	  exit(1)
  end

  def get_rubies(versions_url)
    puts 'Downloading latest list of Rubies from Github...'
    JSON.parse(http_get(versions_url))
  end

  def latest_minor_version(rubies, minor)
    minor_rubies = rubies.map { |n| n['name'] }.select do |n|
      n =~ /^\d+\.\d+\.\d+(-p\d+)?$/ &&
        n.split('.')[0, 2] == minor
    end

    minor_rubies.max_by do |ruby|
      a, b, c, d = *ruby.sub('-p', '.').split('.').map(&:to_i)
      [a, b, c, d || -1]
    end
  end

  def check_eol(version, version_base_url)
    puts "Downloading details for #{version}..."
    details = http_get("#{version_base_url}#{version}")
    puts 'Checking EOL status...'

    return unless details =~ / warn_eol /
    puts "EOL warning found for #{version}!"
    exit 1
  end

  def compare_versions(version, latest, minor)
    puts 'Comparing version numbers...'
    return if version == latest
    puts "Current version is #{version}, but the latest patch release for #{minor.join('.')} is #{latest}!"
    exit 1
  end
end
