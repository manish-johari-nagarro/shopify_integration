class GiftCard

  def add_shopify_obj shopify_gift_card, shopify_api
    @shopify_id = shopify_gift_card['id']
    @last_characters = shopify_gift_card['last_characters']
    @shopify_customer_id = shopify_gift_card['customer_id']
    @initial_balance = shopify_gift_card['initial_balance']
    @balance = shopify_gift_card['balance']
    @note = shopify_gift_card['note']
    @currency = shopify_gift_card['currency']
    @created_at = shopify_gift_card['created_at']
    @disabled_at = shopify_gift_card['disabled_at']
    @expires_on = shopify_gift_card['expires_on']
    self
  end

  def wombat_obj
    {
      'id' => "SHOPIFY-#{@shopify_id.to_s}",
      'shopify_reference' => @last_characters,
      'shopify_customer_id' => @shopify_customer_id,
      'initial_balance' => @initial_balance,
      'amount' => @balance,
      'note' => @note,
      'currency' => @currency,
      'shopify_id' => @shopify_id.to_s,
      'created_at' => @created_at.to_s,
      'disabled_at' => @disabled_at.to_s,
      'expires_on' => @expires_on.to_s
    }
  end

end
