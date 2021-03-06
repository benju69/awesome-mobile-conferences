require('cgi')
require('countries')

README = 'README.md'
PAST = 'PAST.md'
CONTENTS = 'contents.json'

def get_json()
    require 'json'
    JSON.parse(File.read CONTENTS)
end

def output_content_category(c, indent)
  toc = "\n"

  for i in 1..indent
    toc << '#'
  end

  toc << " #{c}\n"
  toc
end

def back_to_top()
  toc = "[back to top](#readme) \n"
  toc << "\n"
  toc
end

def gmapUrl(where)
  url = "https://www.google.com/maps/search/?api=1&query=" + CGI.escape(where)
  url
end

def sort_by_date(dates, direction="ASC")
  sorted = dates.sort
  sorted.reverse! if direction == "DESC"
  sorted
end

def output_single_conf(p)
  o = ""
  where = gmapUrl(p['where'])
  startDate = p['startdate'].split('/')[2]
  endDate = p['enddate'].split('/')[2]
  o << "| #{startDate}"
  if startDate != endDate
    o << " - #{endDate}"
  end
  o << "| [#{p['title']}](#{p['homepage']})"
  o << "|"
  c = ISO3166::Country.find_country_by_name(p['country'])
  if !c.nil?
    o << "#{c.emoji_flag} "
  end
  o << "[#{p['country']}](#{where})"
  o << "| #{p['city']} "
  o << "|"
  if p['callforpaper'] == true
    o << " 🎤 "
  else
    o << " --- "
  end
  o << "|\n"
  o
end

def output_conferences(conferences, year, future)
  o = ""
  currentmonth = 0

  conferences.select { |p| p['year'] == year }
    .sort_by {|k,v| Date.strptime(k['startdate'], '%Y/%m/%d')}
    .each do |p|

      # parse current date
      date = Date.parse p['startdate']

      # check if we need to render only future or previous events
      if future == true
        if date > Date.today
          # manage the month header
          tmp, currentmonth = month_row(currentmonth, date)
          o << tmp
          o << output_single_conf(p)
        end
      else
        if date < Date.today
          tmp, currentmonth = month_row(currentmonth, date)
          o << tmp
          o << output_single_conf(p)
        end
      end
    end
  o
end

def month_row(currentmonth, date)
  o = ""
  # manage the month header
  if currentmonth != date.month
    currentmonth = date.month
    o = "\n"
    o << "## #{date.strftime("%B")}\n"
    o << "| When | Name | Country | City | CfP |\n"
    o << "| --- | --- | --- | --- | --- |\n"
  end
  return o, currentmonth
end

def output_content(j, future)
  toc = ''

  j['years'].each do |c|
    toc << output_content_category(c, 3)
    toc << output_conferences(j['conferences'], c, future)
    toc << back_to_top()
  end
  toc
end

def output_header(j)
  require 'date'
  header       = j['header']
  app          = j['ios_app_link']
  num_projects = j['conferences'].count

  date = DateTime.now
  date_display = date.strftime "%B_%d,_%Y"

  o = header
  o << "\n\n"
  o << "[![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/sindresorhus/awesome)"
  o << " ![](https://img.shields.io/badge/conferences-#{num_projects}-orange.svg)"
  o << " ![](https://img.shields.io/badge/last_update-#{date_display}-green.svg)"
  o << "\n\n"
  o << "## About\n"
  o << "👋 Welcome to **Awesome Mobile Conference** 👋 \n\n"
  o << "A ❤️ curated and 👬👫👭 collaborative list of **#{num_projects}** upcoming 📲  mobile conferences around the world 🌎.\n\n"
  o
end

def output_toc(j)
  toc = "\n\n### Years\n\n"

  j['years'].each do |c|
    id = c
    toc << "- [#{id}](##{id})\n"
  end

  toc
end

def write_readme(j, jj, filename, filenamePast)
  contributing = j['header_contributing']

  output = output_header(j)
  output << "\n\n"
  output << "\n\n## 📌 Upcoming Conferences"
  output << output_content(j, true)
  output << "\n\n## 🕰 Past Conferences"
  output << "\n\n[Browse old conferences](https://github.com/amobconf/awesome-mobile-conferences/blob/master/PAST.md)"
  output << "\n\n\n## 🔰 Legenda\n\n"
  output << "## 📱 Mobile Apps\n\n"
  output << "We developed also two mobile apps to stay always updated, thanks to 💌 push notifications, feel free to download them from 🍏 iOS and 🤖 Play store, link below:\n\n"
  output << "[![Download on the Play Store](https://raw.githubusercontent.com/matteocrippa/awesome-mobile-conferences-android/master/.github/google-play-badge.png)](#{j['android_app_link']})"
  output << "[![Download on the App Store](https://github.com/amobconf/awesome-mobile-conferences/blob/master/.github/appstore.png?raw=true)](#{j['ios_app_link']})"
  output << "\n\n"
  output << "- 🎤  > Call for Paper is open"
  output << "\n\n## ✍️ Contributing\n\n\n"
  output << contributing

  File.open(filename, 'w') { |f| f.write output}
  puts "Wrote #{filename} :-)"

  output = "## 🕰 Past Conferences"
  output << output_content(jj, false)
  File.open(filenamePast, 'w') { |f| f.write output}
  puts "Wrote #{filenamePast} :-)"

end

j = get_json()
jj = get_json()
write_readme(j, jj, README, PAST)
