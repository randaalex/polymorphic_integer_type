require 'spec_helper'

describe PolymorphicIntegerType do

  let(:owner) { Person.create(:name => "Kyle") }
  let(:dog) { Animal.create(:name => "Bela", :kind => "Dog", :owner => owner) }
  let(:cat) { Animal.create(:name => "Alexi", :kind => "Cat") }


  let(:kibble) { Food.create(:name => "Kibble") }
  let(:chocolate) { Food.create(:name => "Choclate") }


  let(:milk) { Drink.create(:name => "milk") }
  let(:water) { Drink.create(:name => "Water") }
  let(:whiskey) { Drink.create(:name => "Whiskey") }

  let(:link) { Link.create(:source => source, :target => target) }

  shared_examples "proper source" do
    it "should have the proper id, type and object for the source" do
      expect(link.source_id).to eql source.id
      expect(link.source_type).to eql source.class.to_s
      expect(link.source).to eql source
    end
  end

  shared_examples "proper target" do
    it "should have the proper id, type and object for the target" do
      expect(link.target_id).to eql target.id
      expect(link.target_type).to eql target.class.to_s
      expect(link.target).to eql target
    end
  end

  context "When a link is given polymorphic record" do
    let(:link) { Link.create(:source => source) }
    let(:source) { cat }
    include_examples "proper source"

    context "and when it already has a polymorphic record" do
      let(:target) { kibble }
      before { link.update_attributes(:target => target) }

      include_examples "proper source"
      include_examples "proper target"

    end

  end

  context "When a link is given polymorphic id and type" do
    let(:link) { Link.create(:source_id => source.id, :source_type => source.class.to_s) }
    let(:source) { cat }
    include_examples "proper source"

    context "and when it already has a polymorphic id and type" do
      let(:target) { kibble }
      before { link.update_attributes(:target_id => target.id, :target_type => target.class.to_s) }
      include_examples "proper source"
      include_examples "proper target"

    end

  end

  context "When using a relation to the links with eagar loading" do
    let!(:links){
      [Link.create(:source => source, :target => kibble),
        Link.create(:source => source, :target => water)]
    }
    let(:source) { cat }

    it "should be able to return the links and the targets" do
      expect(cat.source_links).to match_array links
      expect(cat.source_links.includes(:target).collect(&:target)).to match_array [water, kibble]

    end

  end

  context "When using a through relation to the links with eagar loading" do
    let!(:links){
      [Link.create(:source => source, :target => kibble),
        Link.create(:source => source, :target => water)]
    }
    let(:source) { dog }

    it "should be able to return the links and the targets" do
      expect(owner.pet_source_links).to match_array links
      expect(owner.pet_source_links.includes(:target).collect(&:target)).to match_array [water, kibble]

    end

  end

  context "When eagar loading the polymorphic association" do
    let(:link) { Link.create(:source_id => source.id, :source_type => source.class.to_s) }
    let(:source) { cat }

    context "and when there are multiples sources" do
      let(:link_2) { Link.create(:source_id => source_2.id, :source_type => source_2.class.to_s) }
      let(:source_2) { dog }
      it "should be able to preload both associations" do
        links = Link.includes(:source).where(:id => [link.id, link_2.id]).order(:id)
        expect(l.first.source).to eql cat
        expect(l.last.source).to eql dog
      end

    end

    it "should be able to preload the association" do
      l = Link.includes(:source).where(:id => link.id).first
      expect(l.source).to eql cat
    end


  end

end
