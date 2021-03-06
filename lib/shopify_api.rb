require 'json'
require 'rest-client'
require 'pp'

class ShopifyAPI
  include Shopify::APIHelper

  attr_accessor :order, :config, :payload, :request

  def initialize payload, config={}
    @payload = payload
    @config = config
    Util.set_config @config
  end

  def get_products
    inventories = Array.new
    products = get_objs('products', Product)
    products.each do |product|
      unless product.variants.nil?
        product.variants.each do |variant|
          unless variant.sku.blank?
            inventory = Inventory.new
            inventory.add_obj variant
            inventories << inventory.wombat_obj
          end
        end
      end
    end

    {
      'objects' => Util.wombat_array(products),
      'message' => "Successfully retrieved #{products.length} products from Shopify.",
      'additional_objs' => inventories,
      'additional_objs_name' => 'inventory'
    }
  end

  def get_customers
    get_webhook_results 'customers', Customer
  end

  def get_inventory
    inventories = Array.new
    get_objs('products', Product).each do |product|
      unless product.variants.nil?
        product.variants.each do |variant|
          unless variant.sku.blank?
            inventory = Inventory.new
            inventory.add_obj variant
            inventories << inventory.wombat_obj
          end
        end
      end
    end
    get_reply inventories, "Retrieved inventories."
  end

  def get_shipments
    shipments = []
    get_objs('orders', Order).each do |order|
      shipments += shipments(order.shopify_id)
    end
    get_webhook_results 'shipments', shipments, false
  end

  def get_gift_cards
    gift_cards = get_objs('gift_cards', GiftCard)
    get_webhook_results 'gift_cards', gift_cards, false
  end

  def get_orders
    orders = get_objs('orders', Order)
    response = get_webhook_results 'orders', orders, false

    # config to return corresponding shipments
    if @config[:create_shipments].to_i == 1
      shipments = []
      orders.each do |order|
        order.shipments.each do |shipment|
          shipments << shipment.wombat_obj
        end
      end
      response.merge!({
        'additional_objs' => shipments,
        'additional_objs_name' => 'shipment'
      })
    end

    response
  end

  # add or update
  def add_product
    product = Product.new
    product.add_wombat_obj @payload['product'], self

    shopify_id, variant_shopify_id = find_product_and_variant_shopify_id_by_sku(product.sku)

    added_or_updated = "added"
    result = if shopify_id.blank?
      # we should continue adding
      api_post 'products.json', product.shopify_obj
    else
      # update instead
      product_shopify_obj = product.shopify_obj
      product_shopify_obj["product"]["variants"][0]["id"] = variant_shopify_id
      added_or_updated = "updated"
      api_put "products/#{shopify_id}.json", product_shopify_obj
    end

    {
      'objects' => result,
      'message' => "Product added with Shopify ID of #{result['product']['id']} was #{added_or_updated}"
    }
  end

  # add or update
  def add_customer
    customer = Customer.new
    customer.add_wombat_obj @payload['customer'], self

    shopify_id = find_customer_by_email(customer.email)

    added_or_updated = "added"
    result = if shopify_id.blank?
      # we should continue adding
      api_post 'customers.json', customer.shopify_obj
    else
      # update instead
      added_or_updated = "updated"
      begin
        api_put "customers/#{shopify_id}.json", customer.shopify_obj
      rescue RestClient::UnprocessableEntity => e
        # retries without addresses to avoid duplication bug
        customer_without_addresses = customer.shopify_obj
        customer_without_addresses["customer"].delete("addresses")

        api_put "customers/#{shopify_id}.json", customer_without_addresses
      end
    end

    {
      'objects' => result,
      'message' => "Customer with Shopify ID of #{result['customer']['id']} was #{added_or_updated}"
    }
  end

  def set_inventory
    inventory = Inventory.new
    inventory.add_wombat_obj @payload['inventory']
    puts "INV: " + @payload['inventory'].to_json
    shopify_id = inventory.shopify_id.blank? ? find_variant_shopify_id_by_sku(inventory.sku) : inventory.shopify_id

    message = 'Could not find item with SKU of ' + inventory.sku
    
    unless shopify_id.blank?
      result = api_put "variants/#{shopify_id}.json", {'variant' => inventory.shopify_obj}
      message = "Set inventory of SKU #{inventory.sku} " +  "to #{inventory.quantity}."
    end

    {
      'objects' => result,
      'message' => message
    }
  end

  def add_metafield obj_name, shopify_id, wombat_id
    api_obj_name = (obj_name == "inventory" ? "product" : obj_name)

    api_post "#{api_obj_name}s/#{shopify_id}/metafields.json",
             Metafield.new(@payload[obj_name]['id']).shopify_obj
  end

  def wombat_id_metafield obj_name, shopify_id
    wombat_id = nil

    api_obj_name = (obj_name == "inventory" ? "product" : obj_name)

    metafields_array = api_get "#{api_obj_name}s/#{shopify_id}/metafields"
    unless metafields_array.nil? || metafields_array['metafields'].nil?
      metafields_array['metafields'].each do |metafield|
        if metafield['key'] == 'wombat_id'
          wombat_id = metafield['value']
          break
        end
      end
    end

    wombat_id
  end

  def order order_id
    get_objs "orders/#{order_id}", Order
  end

  def transactions order_id
    get_objs "orders/#{order_id}/transactions", Transaction
  end

  def shipments order_id
    get_objs "orders/#{order_id}/fulfillments", Shipment
  end
 
  private

  def get_webhook_results obj_name, obj, get_objs = true
    objs = Util.wombat_array(get_objs ? get_objs(obj_name, obj) : obj)
    get_reply objs, "Successfully retrieved #{objs.length} #{obj_name} from Shopify."
  end

  def get_reply objs, message
    {
      'objects' => objs,
      'message' => message
    }
  end

  def get_objs objs_name, obj_class
    objs = Array.new
    shopify_objs = api_get objs_name
    if shopify_objs.values.first.kind_of?(Array)
      shopify_objs.values.first.each do |shopify_obj|
        obj = obj_class.new
        obj.add_shopify_obj shopify_obj, self
        objs << obj
      end
    else
      obj = obj_class.new
      obj.add_shopify_obj shopify_objs.values.first, self
      objs << obj
    end
    objs
  end

  def find_variant_shopify_id(product_shopify_id, variant_sku)
    variants = api_get("products/#{product_shopify_id}/variants")["variants"]

    if variant = variants.find {|v| v["sku"] == variant_sku}
      variant["id"]
    end
  end

  def find_customer_by_email email
    customers = api_get('customers/search', { 'query' => "email:#{email}"})

    sleep 1

    customers['customers'].each do |customer|
      return customer['id'] if customer['email'] = email
    end

    return nil
  end

  def find_product_and_variant_shopify_id_by_sku sku
    count = (api_get 'products/count')['count']
    page_size = 250
    pages = (count / page_size.to_f).ceil
    current_page = 1

    while current_page <= pages do
      sleep 1

      products = api_get('products', {'limit' => page_size, 'page' => current_page, 'product_type' => sku})
      current_page += 1
      products['products'].each do |product|
        product['variants'].each do |variant|
          return product['id'].to_s, variant['id'].to_s if variant['sku'] == sku
        end
      end
    end

    return nil
  end

  def find_variant_shopify_id_by_sku sku
    count = (api_get 'products/count')['count']
    page_size = 250
    pages = (count / page_size.to_f).ceil
    current_page = 1

    while current_page <= pages do
      sleep 1

      products = api_get('products', {'limit' => page_size, 'page' => current_page, 'product_type' => sku})
      current_page += 1
      products['products'].each do |product|
        product['variants'].each do |variant|
          return variant['id'].to_s if variant['sku'] == sku
        end
      end
    end

    return nil
  end
end

class AuthenticationError < StandardError; end
class ShopifyError < StandardError; end
