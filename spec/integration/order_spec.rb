require 'spec_helper'

RSpec.shared_examples "import orders" do
  it 'imports orders totals' do
    subject.wombat_obj.tap do |order|
      expect(order['totals']['order']).to eq(shopify_order['total_price'].to_f)
      expect(order['totals']['item']).to eq(shopify_order['total_line_items_price'].to_f)
      expect(order['line_items'].count).to eq(shopify_order['line_items'].count)
    end
  end

  it 'should include discounts totals' do
    subject.wombat_obj.tap do |order|
      expect(order['totals']).to have_key('totals_discounts')
    end
  end

  it 'add up all items promotions to shopifys order total discount' do
    subject.wombat_obj.tap do |order|
      expect(order['line_items'].map{|item| item['promo_total']}.sum.round(2)).to eq(shopify_order['total_discounts'].to_f)
    end
  end
end

RSpec.shared_examples "line items totals" do |totals|
  it 'renders the right price of each line item' do
    subject.wombat_obj.tap do |order|
      order['line_items'].each do |item|
        expect(item['price']).to eq(totals[item['product_id']]['price'])
        expect(item['quantity']).to eq(totals[item['product_id']]['quantity'])
        expect(item['promo_item']).to eq(totals[item['product_id']]['promo_item'])
        expect(item['promo_total']).to eq(totals[item['product_id']]['promo_total'])
      end
    end
  end
end

RSpec.describe ::Order, type: :model do
  include OrderHelpers
  include OrderDiscountHelpers
  include OrderFixDiscountHelpers
  include OrderLineItemDiscountHelpers
  include OrderShipmentHelpers
  include OrderCompleteHelpers

  let(:shopify_api) {
    double(
      transactions: [],
      config: {}
      )
  }

  before do
    expect(Util).to receive(:shopify_host).with(any_args).at_least(:once).and_return("host")
    expect(Util).to receive(:config).at_least(:once).and_return({
        pos_stock_location: "",
        ecomm_stock_location: "",
      })
  end

  describe '#wombat_obj' do
    context 'simple order' do
      let(:shopify_order) { simple_order }
      subject { described_class.new.add_shopify_obj(shopify_order, shopify_api) }

      include_examples "import orders"
      it_behaves_like 'line items totals', {
        "11.BDG.BOPT.2.0" => { 'quantity' => 5, 'price' => 1.0, 'promo_item' => 0.0, 'promo_total' => 0.0 },
        "12.TEE.STPK.5.4" => { 'quantity' => 5, 'price' => 38.0, 'promo_item' => 0.0, 'promo_total' => 0.0 },
        "12.SHT.WKFW.3.4" => { 'quantity' => 5, 'price' => 118.0, 'promo_item' => 0.0, 'promo_total' => 0.0 },
      }
    end

    context 'order with a 10 percent discounts' do
      let(:shopify_order) { discount_order }
      subject { described_class.new.add_shopify_obj(shopify_order, shopify_api) }

      include_examples "import orders"
      it_behaves_like 'line items totals', {
        "11.BDG.BOPT.2.0" => { 'quantity' => 5, 'price' => 1.0, 'promo_item' => 0.1, 'promo_total' => 0.1 * 5 },
        "12.TEE.STPK.5.4" => { 'quantity' => 5, 'price' => 38.0, 'promo_item' => 3.8, 'promo_total' => 3.8 * 5 },
        "12.SHT.WKFW.3.4" => { 'quantity' => 5, 'price' => 118.0, 'promo_item' => 11.8, 'promo_total' => 11.8 * 5 },
      }
    end

    context 'order with 100$ fix amount discounts' do
      let(:shopify_order) { fix_discount_order }
      subject { described_class.new.add_shopify_obj(shopify_order, shopify_api) }

      include_examples "import orders"
      it_behaves_like 'line items totals', {
        "11.BDG.BOPT.2.0" => { 'quantity' => 5, 'price' => 1.0, 'promo_item' => 0.12738853503184713, 'promo_total' => 0.12738853503184713 * 5 },
        "12.TEE.STPK.5.4" => { 'quantity' => 5, 'price' => 38.0, 'promo_item' => 4.840764331210191, 'promo_total' => 4.840764331210191 * 5 },
        "12.SHT.WKFW.3.4" => { 'quantity' => 5, 'price' => 118.0, 'promo_item' => 15.031847133757962, 'promo_total' => 15.031847133757962 * 5},
      }
    end

    context 'order with 10% line item discounts' do
      let(:shopify_order) { line_item_discount_order }
      subject { described_class.new.add_shopify_obj(shopify_order, shopify_api) }

      include_examples "import orders"
      it_behaves_like 'line items totals', {
        "11.BDG.BOPT.2.0" => { 'quantity' => 5, 'price' => 1.0, 'promo_item' => 0.1, 'promo_total' => 0.1 * 5 },
        "12.TEE.STPK.5.4" => { 'quantity' => 5, 'price' => 38.0, 'promo_item' => 3.8, 'promo_total' => 3.8 * 5 },
        "12.SHT.WKFW.3.4" => { 'quantity' => 5, 'price' => 118.0, 'promo_item' => 11.8, 'promo_total' => 11.8 * 5 },
      }
    end


    context 'order with shipments' do
      let(:shopify_order) { shipment_order }
      subject { described_class.new.add_shopify_obj(shopify_order, shopify_api) }

      include_examples "import orders"
      it_behaves_like 'line items totals', {
        "11.BDG.BOPT.2.0" => { 'quantity' => 5, 'price' => 1.0, 'promo_item' => 0.0, 'promo_total' => 0.0 },
        "12.TEE.STPK.5.4" => { 'quantity' => 5, 'price' => 38.0, 'promo_item' => 0.0, 'promo_total' => 0.0 },
        "12.SHT.WKFW.3.4" => { 'quantity' => 5, 'price' => 118.0, 'promo_item' => 0.0, 'promo_total' => 0.0 },
      }
    end

    context 'complete order' do
      let(:shopify_order) { complete_order }
      subject { described_class.new.add_shopify_obj(shopify_order, shopify_api) }

      include_examples "import orders"
      it_behaves_like 'line items totals', {
        "11.BDG.BOPT.2.0" => { 'quantity' => 5, 'price' => 1.0, 'promo_item' => 0.09248407643312102, 'promo_total' => 0.09248407643312102 * 5},
        "12.TEE.STPK.5.4" => { 'quantity' => 5, 'price' => 38.0, 'promo_item' => 3.514394904458599, 'promo_total' => 3.514394904458599 * 5},
        "12.SHT.WKFW.3.4" => { 'quantity' => 5, 'price' => 118.0, 'promo_item' => 22.71312101910828, 'promo_total' => 22.71312101910828 * 5},
      }
    end
  end
end
