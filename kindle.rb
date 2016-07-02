# This primitive program parses my_clipping.txt, a text file on your kindle which stores all your highlights and notes. 
# This is very basic at the moment, I'll upgrade this in due course of time. Currently, highlights are not sorted by page number or location. 
# I'll update to include that too; and also provide reference to page numbers so that you can easily refer back. 
# Let me know in case of any problems. 

require 'pp'
require "csv"

# This method processes each note added to my_clipping.txt
def process_each_comment comment

	quote1_markerstring = "\r\n\r\n"
	quote2_markerstring = "\r\n"

	quote = comment[/#{quote1_markerstring}(.*?)#{quote2_markerstring}/m, 1].strip
	bookname_and_page = comment.split("|").first

	tmp = bookname_and_page.split("\r\n")
	bookname = tmp.first.strip
	page = tmp.last.strip
	[quote,bookname,page]

end


# Quote character normalized
def clear_unwanted_quotes q

	q = q.gsub("‘","'")
	q = q.gsub("’","'")
	q = q.gsub("“","'")
	q = q.gsub("”","'")

	q
end


# Read my_clipping.txt
# Tokenize each note and comment and handover to process_each_comment for further processing
def beautify_kindle_quotes
	# encoding: UTF-8
	file = File.open("my_clipping.txt","r")
	clips = []

	book_and_quotes = Hash.new { |hash, key| hash[key] = [] }

	comment = ""	

	file.each_line do |line|

		unless line == "==========\r\n"
			comment = comment + line 
		else
			clips << comment
			comment = ""
		end
	end


	clips.each do |x|
		res = process_each_comment x
		book_and_quotes[res[1]] << res[0]
	end


	CSV.open("kindle_notes.csv", "w:UTF-8") do |csv|
		csv << ["Book Name", "Quote"]

		book_and_quotes.each do |bookname,quote|
			bookname = bookname.gsub("""","").strip
			quote.each do |q|
				csv << [bookname,clear_unwanted_quotes q]
			end
		end
	end
end


beautify_kindle_quotes

