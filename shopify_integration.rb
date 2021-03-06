require "sinatra"
require "endpoint_base"

require_all 'lib'

class ShopifyIntegration < EndpointBase::Sinatra::Base

  require "pry" if ShopifyIntegration.development?

  post '/*_shipment' do # /add_shipment or /update_shipment
    summary = Shopify::Shipment.new(@payload['shipment'], @config).ship!

    result 200, summary
  end

  ## Supported endpoints:
  ## get_ for orders, products, inventories, shipments, customers
  ## add_ for product, customer -- idempotent add or update
  ## update_ for product, customer
  ## set_inventory
  post '/*_*' do |action, obj_name|
    shopify_action "#{action}_#{obj_name}", obj_name.singularize
  end

  private

    def shopify_action action, obj_name
      begin
        action_type = action.split('_')[0]

        ## Add and update shouldn't come with a shopify_id, therefore when
        ## they do, it indicates Wombat resending an object.
        shopify = ShopifyAPI.new(@payload, @config)
        response = shopify.send(action)

        case action_type
        when 'get'
          response['objects'].each do |obj|
            add_object obj_name, obj
          end

          last_object = response['objects'].last
          unless last_object.nil?
            # add_parameter 'since', last_object['updated_at'] unless last_object.nil? # Time.now.utc.iso8601
            add_parameter 'since_id', last_object['shopify_id']
            add_parameter 'page', @config['page'].to_i + 1 unless @config['page'].nil?
          end
        when 'add'
          ## This will do a partial update in Wombat, only the new key
          ## shopify_id will be added, everything else will be the same
          sleep 1
          add_object obj_name, { 'id' => @payload[obj_name]['id'], 'shopify_id' => response['objects'][obj_name]['id'].to_s }

          ## Add metafield to track Wombat ID
          shopify.add_metafield obj_name, response['objects'][obj_name]['id'].to_s, @payload[obj_name]['id']
        end

        if response.has_key?('additional_objs') && response.has_key?('additional_objs_name')
          response['additional_objs'].each do |obj|
            add_object response['additional_objs_name'], obj
          end
        end

        # avoids "Successfully retrieved 0 customers from Shopify."
        if skip_summary?(response, action_type)
          return result 200
        else
          return result 200, response['message']
        end
      rescue => e
        print e.cause
        print e.backtrace.join("\n")
        result 500, (e.try(:response) ? e.response : e.message)
      end
    end

    def skip_summary?(response, action_type)
      response['message'].nil? || get_without_objects?(response, action_type)
    end

    def get_without_objects?(response, action_type)
      action_type == 'get' && response['objects'].to_a.size == 0
    end
end
