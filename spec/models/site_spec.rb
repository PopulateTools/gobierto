require 'rails_helper'

RSpec.describe Site, type: :model do
  describe '#configuration' do
    it 'should be an SiteConfiguration object by default' do
      expect(subject.configuration.class).to be(SiteConfiguration)
      expect(subject.configuration.to_h).to eq({})
    end

    context 'an existing site' do
      let(:subject) { create_site }

      it 'should be able to store attributes' do
        expect(subject.configuration.foo).to be_nil

        subject.configuration.foo = 'bar'
        subject.save!

        subject.reload
        expect(subject.configuration.foo).to eq('bar')
      end
    end
  end

  describe '#subdomain' do
    it 'should return nil if domain is nil' do
      expect(subject.domain).to be_nil
      expect(subject.subdomain).to be_nil
    end

    it 'should return the first segment of the domain' do
      subject.domain = 'foo.bar.com'
      expect(subject.subdomain).to eq('foo')
    end
  end

end
