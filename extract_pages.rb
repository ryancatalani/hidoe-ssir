require 'hexapdf'

page_num = 4 # Page 5

Dir.entries("pdfs").reject{|f| File.directory? f}.each do |fname|

	extracted = HexaPDF::Document.new
	original = HexaPDF::Document.open("pdfs/#{fname}")

	extracted.pages << extracted.import(original.pages[4])
	extracted.write("extracted_p5/#{fname}")

end