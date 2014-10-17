class WebSearch < Search
  include Govboxable

  attr_reader :matching_site_limits, :tracking_information

  def initialize(options = {})
    super(options)
    @options = options
    offset = (@page - 1) * @per_page
    formatted_query_instance = "#{@affiliate.search_engine}FormattedQuery".constantize.new(@query, domains_scope_options)
    @matching_site_limits = formatted_query_instance.matching_site_limits
    @formatted_query = formatted_query_instance.query
    search_engine_parameters = options.merge(query: @formatted_query, offset: offset, per_page: @per_page).merge(google_credentials_override)
    @search_engine = search_engine_klass(@affiliate.search_engine).new(search_engine_parameters)
  end

  def cache_key
    [@formatted_query, @options.remove(:affiliate).merge(affiliate_id: @affiliate.id), @affiliate.search_engine].join(':')
  end

  protected
  def search_engine_klass(search_engine_option)
    "#{search_engine_option}#{get_vertical.to_s.classify}Search".constantize
  end

  def domains_scope_options
    DomainScopeOptionsBuilder.build @affiliate, @options[:site_limits]
  end

  def result_hash
    hash = super
    unless @error_message
      hash.merge!(:spelling_suggestion => @spelling_suggestion) if @spelling_suggestion
      hash.merge!(:boosted_results => boosted_contents.results) if has_boosted_contents?
      hash.merge!(:jobs => jobs) if jobs.present?
    end
    hash
  end

  def search
    ActiveSupport::Notifications.instrument("#{@search_engine.class.name.tableize.singularize}.usasearch", :query => { :term => @search_engine.query }) do
      @search_engine.execute_query
    end
  rescue SearchEngine::SearchError => error
    Rails.logger.warn "Error getting search results from #{@search_engine.class.name} API endpoint: #{error}"
    false
  end

  def handle_response(response)
    @total = response.total rescue 0
    available_search_engine_pages = (@total/@per_page.to_f).ceil

    if backfill_needed?
      odie_search = initialize_odie_search(available_search_engine_pages)
      odie_response = run_odie_search_and_handle_response(odie_search, available_search_engine_pages)
      if odie_response && odie_response.total.zero? && odie_response.suggestion
        suggestion = odie_response.suggestion
        @spelling_suggestion = suggestion.highlighted
        odie_search = initialize_odie_search(available_search_engine_pages, suggestion.text)
        run_odie_search_and_handle_response(odie_search, available_search_engine_pages)
      end
    end

    handle_search_engine_response(response) if available_search_engine_pages >= @page
    assign_module_tag
  end

  def initialize_odie_search(available_search_engine_pages, query = nil)
    odie_search_params = @options.merge(per_page: self.default_per_page,
                                        page: [@page - available_search_engine_pages, 1].max)
    odie_search_params[:query] = query if query
    odie_search_class.new odie_search_params
  end

  def run_odie_search_and_handle_response(odie_search, available_search_engine_pages)
    odie_response = odie_search.search
    if odie_response and odie_response.total > 0
      adjusted_total = available_search_engine_pages * @per_page + odie_response.total
      if @total <= @per_page * (@page - 1) and available_search_engine_pages < @page
        temp_total = @total
        @total = adjusted_total
        @results = paginate(odie_search.process_results(odie_response))
        @total = temp_total
        @startrecord = (@page -1) * @per_page + 1
        @endrecord = @startrecord + odie_response.results.size - 1
        @indexed_results = odie_response
      end
      @total = adjusted_total
    end
    odie_response
  end

  def handle_search_engine_response(response)
    @startrecord = response.start_record
    @results = paginate(post_process_results(response.results))
    @endrecord = response.end_record
    @spelling_suggestion = response.spelling_suggestion
    @tracking_information = response.tracking_information
  end

  def backfill_needed?
    @total < @per_page * @page
  end

  def assign_module_tag
    @module_tag = nil
    if @total > 0
      if @indexed_results.present?
        @module_tag = local_index_module_tag
      else
        @module_tag = module_tag_for_search_engine(@affiliate.search_engine)
      end
    end
  end

  def local_index_module_tag
    'AIDOC'
  end

  def module_tag_for_search_engine(search_engine)
    search_engine == 'Bing' ? 'BWEB' : 'GWEB'
  end

  def post_process_results(results)
    sitelink_generators = Sitelinks::Generators.classes_by_names sitelink_generator_names
    post_processor = WebResultsPostProcessor.new(@query, @affiliate, results, sitelink_generators)
    post_processor.post_processed_results
  end

  def sitelink_generator_names
    @affiliate.sitelink_generator_names
  end

  def populate_additional_results
    @govbox_set = GovboxSet.new(query, affiliate, @options[:geoip_info]) if first_page?
  end

  def log_serp_impressions
    @modules << module_tag if module_tag
    @modules |= spelling_suggestion_modules
    @modules << "SREL" if self.has_related_searches?
    @modules << 'NEWS' if self.has_news_items?
    @modules << 'VIDS' if self.has_video_news_items?
    @modules << "BBG" if self.has_featured_collections?
    @modules << "BOOS" if self.has_boosted_contents?
    @modules << "MEDL" unless self.med_topic.nil?
    @modules << "JOBS" if self.jobs.present?
    @modules << "TWEET" if self.has_tweets?
    BestBetImpressionsLogger.log(affiliate.id, @query, featured_collections, boosted_contents)
  end

  def spelling_suggestion_modules
    return [] unless spelling_suggestion
    commercial_results? ? %w(OVER BSPEL) : %w(LOVER SPEL)
  end

  def odie_search_class
    OdieSearch
  end

  def get_vertical
    :web
  end

  def google_credentials_override
    google_credentials_overridden? ? { google_cx: @affiliate.google_cx, google_key: @affiliate.google_key } : {}
  end

  def google_credentials_overridden?
    @affiliate.search_engine == 'Google' && @affiliate.google_cx.present? && @affiliate.google_key.present?
  end

end
