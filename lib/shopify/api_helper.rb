module Shopify
  module APIHelper
    def api_get resource, data = {}
      params = ''
      unless data.empty?
        params = '?'
        data.each do |key, value|
          params += '&' unless params == '?'
          params += "#{key}=#{value}"
        end
      end
      response = RestClient.get shopify_url + (final_resource resource) + params
      JSON.parse response.force_encoding("utf-8")
    end

    def api_post resource, data
      response = RestClient.post shopify_url + resource, data.to_json,
        :content_type => :json, :accept => :json
      JSON.parse response.force_encoding("utf-8")
    end

    def api_put resource, data
      response = RestClient.put shopify_url + resource, data.to_json,
        :content_type => :json, :accept => :json
      JSON.parse response.force_encoding("utf-8")
    end

    def shopify_url
      "https://#{Util.shopify_apikey @config}:#{Util.shopify_password @config}" +
      "@#{Util.shopify_host @config}/admin/"
    end

    def final_resource resource
      if !@config['since'].nil?
        resource += ".json?updated_at_min=#{@config['since']}"
        resource += "&status=#{@config['status']}" unless @config['status'].nil?
        resource += "&fulfillment_status=#{@config['fulfillment_status']}" unless @config['fulfillment_status'].nil?
        resource += "&financial_status=#{@config['financial_status']}" unless @config['financial_status'].nil?
        resource += "&limit=#{@config['limit']}" unless @config['limit'].nil?
        resource += "&since_id=#{@config['since_id']}" unless @config['since_id'].nil?
        resource += "&page=#{@config['page']}" unless @config['page'].nil?
      elsif !@config['id'].nil?
        resource += "/#{@config['id']}.json"
      else
        resource += '.json'
      end
      resource
    end
  end
end

