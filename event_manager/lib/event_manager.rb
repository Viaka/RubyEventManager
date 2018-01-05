require "csv"
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def clean_phone(phone)
  phone = phone.to_s.gsub(/\D/, '')
  bad_no = "0000000000"
  if (phone.length) < 10 || (phone.length == 11 && phone[0] != "1") || (phone.length > 11)
    bad_no
  else
    phone.rjust(11,"0")[1..11]
  end
end

def parse_hours(regdate, hours)
  regdate = DateTime.strptime(regdate, "%m/%d/%y %k:%M")

  hours[regdate.hour - 1] += 1
  
  

end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  
  begin
  civic_info.representative_info_by_address(
      address: zipcode, 
      levels: 'country', 
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
  ).officials
  
  #legislator_names = legislators.map(&:name)
  #legislators_string = legislator_names.join(", ")
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials" 
  end
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"
  
  filename = "output/thanks_#{id}.html"
  
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
hours = Array.new(24, 0)
template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  
  
  zipcode = clean_zipcode(row[:zipcode])

  phone = clean_phone(row[:homephone])
  
  pHours = parse_hours(row[:regdate], hours)
  
  legislators = legislators_by_zipcode(zipcode)
  
  form_letter = erb_template.result(binding)
  #save_thank_you_letters(id, form_letter)
  
  #puts form_letter
end
puts "Hours: 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24".rjust(80)
puts "Signups: #{hours.to_s}".rjust(80)