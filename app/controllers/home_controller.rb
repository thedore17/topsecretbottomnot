class HomeController < ApplicationController
  NytimesArticle.api_key = NYT_API_KEY

  TRANSPARENCY_SERVER = "transparencydata.com"
  TRANSPARENCY_BASE_PATH = "/api/1.0/"
  ENTITY_PATH = "#{TRANSPARENCY_BASE_PATH}entities.json"
  INDUSTRIES_PATH = "#{TRANSPARENCY_BASE_PATH}aggregates/pol/%s/contributors/industries.json"

  CONGRESS_SERVER = 'congress.api.sunlightfoundation.com'
  BILLS_BASE_PATH = '/bills'
  BILL_SEARCH_BASE_PATH = '/bills/search'

  def index
    return if params['u'].blank?
    url = params['u']

    # remove the query string or else NYT article search chokes
    question_mark_pos = url.index("?")
    if question_mark_pos.present?
      url = url[0..question_mark_pos-1]
    end

    # find keywords for the URL
    kw = get_keywords_for_url(url)
    if kw.nil? || kw.empty?
      raise "No keywords for article"
    end

    query_string = kw.join(" ").gsub(/[^a-zA-Z ]/, "").split(/ +/).join(" OR ")

    bills = get_bills_for_keyword(query_string)

    logger.debug "Found #{bills.size} bills"
    r = []
    bills.each do |b|
      logger.debug "Found #{b.inspect}"
      next unless b.has_key?(:bill_id)
      r << get_data_for_bill_id(b[:bill_id])
    end

    logger.debug "Sending #{r.to_json}"

    render json: r
  end

  private

  def get_keywords_for_url(url)
    articles = NytimesArticle.search(:fq => "web_url:\"#{url}\"")
    if articles["response"]['docs'].size == 0
      raise "Nothing found at #{url}"
    end
    articles["response"]['docs'][0]['keywords'].collect{|x| x['value']}
  end

  def get_entity_id(name, type)
    query = URI.encode_www_form({:apikey => SUNLIGHT_API_KEY, :search => name, :type => type})
    uri = URI::HTTP.build :host => TRANSPARENCY_SERVER, :path => ENTITY_PATH, :query => query
    reply        = uri.read
    parsed_reply = JSON.parse reply
    return parsed_reply[0]["id"] if parsed_reply.size > 0
  end

  def get_top_contributors(entity)
    query = URI.encode_www_form({:apikey => SUNLIGHT_API_KEY})
    uri = URI::HTTP.build :host => TRANSPARENCY_SERVER, :path => INDUSTRIES_PATH % entity, :query => query
    reply        = uri.read
    parsed_reply = JSON.parse reply
    parsed_reply
  end

  def get_bills_for_keyword(keyword)
    query = URI.encode_www_form({:apikey => SUNLIGHT_API_KEY, :query => keyword, :order => "active_at", :per_page => 5})
    uri = URI::HTTP.build :host => CONGRESS_SERVER, :path => BILL_SEARCH_BASE_PATH, :query => query
    logger.debug "get_bills_for_keyword(#{keyword}): #{uri}"

    reply        = uri.read
    parsed_reply = JSON.parse reply

    result = []
    return unless parsed_reply["results"].present?

    parsed_reply["results"].each do |r|
      is_active = r["history"]["active"]
      next unless is_active

      bill_id = r["bill_id"]
      active_at = Date.parse(r["history"]["active_at"]).to_s
      cosponsors_count = r["cosponsors_count"]
      result << {:bill_id => bill_id, :active_at => active_at, :cosponsors_count => cosponsors_count}
    end

    result
  end

  def get_data_for_bill_id(bill_id)
    logger.debug "get_data_for_bill_id(#{bill_id})"

    bill_number = bill_id.split("-").first

    query = URI.encode_www_form({:apikey => SUNLIGHT_API_KEY, :bill_id => bill_id, :fields=>"sponsor,cosponsors,short_title,popular_title,official_title"})
    uri = URI::HTTP.build :host => CONGRESS_SERVER, :path => BILLS_BASE_PATH, :query => query
    reply        = uri.read
    parsed_reply = JSON.parse reply

    result = {:sponsor => {}, :party => {}, :bill_number => bill_number.to_s.upcase}

    return if parsed_reply["count"] == 0

    result[:title] = parsed_reply["results"][0]['official_title']
    result[:sponsor][:twitter_id] = parsed_reply["results"][0]['sponsor']['twitter_id']
    result[:sponsor][:name] = parsed_reply["results"][0]['sponsor']['first_name'] + " " + parsed_reply["results"][0]['sponsor']['last_name']

    sponsor_party = parsed_reply["results"][0]['sponsor']['party']
    result[:party][sponsor_party] = 1

    parsed_reply["results"][0]['cosponsors'].each do |cs|
      cs_party = cs['legislator']['party']

      unless result[:party].has_key?(cs_party)
        result[:party][cs_party] = 0
      end

      result[:party][cs_party] += 1
    end

    result
  end
end
