require 'httparty'
require 'smarter_csv'
require 'down'
require 'json'

def create_url(code, suffix)
	"https://arch-prod-reports-repository.s3-us-west-1.amazonaws.com/ssir/2020/#{code}SSIR-#{suffix}.pdf"
end

def try_download(code, url)
	if HTTParty.head(url).code == 200
		begin
			Down.download(url, destination: "pdfs/#{code}.pdf")
			puts "#{code}: Success #{url}"
			return url
		rescue
			puts "#{code}: Code 200 but Down error #{url}"
		end
	end
	return false
end

possible_suffixes = %w(1 2 3 4 5 6 7 C)
final_school_urls = []

begin

	schools = SmarterCSV.process('schools.csv', convert_values_to_numeric: false)
	schools.each do |school|

		code = school[:sch_code]
		suffix = school[:probablesuffix]
		url = create_url(code, suffix)

		final_url = try_download(code, url)
		if final_url == false
			possible_suffixes.each do |possible|
				puts "#{code}: Trying suffix #{possible}"
				final_url = try_download(code, url)
				break if final_url != false
			end
		end

		final_school_urls << {
			code: code,
			url: final_url
		}

	end

ensure

	# Save progress
	File.open("urls-#{Time.now.to_i}.json","w") do |f|
	  f.write(JSON.pretty_generate(final_school_urls))
	end

end