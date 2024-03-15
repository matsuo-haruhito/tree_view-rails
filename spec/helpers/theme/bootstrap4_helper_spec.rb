# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Theme::Bootstrap4Helper, type: :helper do
  describe 'date_field' do
    it do
      expect(date_field).to include('class="form-control"')
      expect(date_field(nil, nil, class: nil)).to_not include('class=')
      expect(date_field(nil, nil, class: '')).to include('class=""')
      expect(date_field(nil, nil, class: 'foo')).to include('class="foo"')
    end
  end

  describe 'datetime_field' do
    it do
      expect(datetime_field).to include('class="form-control"')
      expect(datetime_field(nil, nil, class: nil)).to_not include('class=')
      expect(datetime_field(nil, nil, class: '')).to include('class=""')
      expect(datetime_field(nil, nil, class: 'foo')).to include('class="foo"')
    end
  end

  describe 'number_field' do
    it do
      expect(number_field).to include('class="form-control"')
      expect(number_field(nil, nil, class: nil)).to_not include('class=')
      expect(number_field(nil, nil, class: '')).to include('class=""')
      expect(number_field(nil, nil, class: 'foo')).to include('class="foo"')
    end
  end

  describe 'password_field' do
    it do
      expect(password_field).to include('class="form-control"')
      expect(password_field(nil, nil, class: nil)).to_not include('class=')
      expect(password_field(nil, nil, class: '')).to include('class=""')
      expect(password_field(nil, nil, class: 'foo')).to include('class="foo"')
    end
  end

  describe 'search_field' do
    it do
      expect(search_field).to include('class="form-control"')
      expect(search_field(nil, nil, class: nil)).to_not include('class=')
      expect(search_field(nil, nil, class: '')).to include('class=""')
      expect(search_field(nil, nil, class: 'foo')).to include('class="foo"')
    end
  end

  describe 'text_area' do
    it do
      expect(text_area).to include('class="form-control"')
      expect(text_area(nil, nil, class: nil)).to_not include('class=')
      expect(text_area(nil, nil, class: '')).to include('class=""')
      expect(text_area(nil, nil, class: 'foo')).to include('class="foo"')
    end
  end

  describe 'text_field' do
    it do
      expect(text_field).to include('class="form-control"')
      expect(text_field(nil, nil, class: nil)).to_not include('class=')
      expect(text_field(nil, nil, class: '')).to include('class=""')
      expect(text_field(nil, nil, class: 'foo')).to include('class="foo"')
    end
  end

  describe 'text_field_tag' do
    it do
      expect(text_field_tag).to include('class="form-control"')
      expect(text_field_tag(nil, nil, class: nil)).to_not include('class=')
      expect(text_field_tag(nil, nil, class: '')).to include('class=""')
      expect(text_field_tag(nil, nil, class: 'foo')).to include('class="foo"')
    end
  end

  describe 'select_tag' do
    it do
      expect(select_tag).to include('class="form-control"')
      expect(select_tag(nil, nil, class: nil)).to_not include('class=')
      expect(select_tag(nil, nil, class: '')).to include('class=""')
      expect(select_tag(nil, nil, class: 'foo')).to include('class="foo"')
    end
  end

  describe 'submit_tag' do
    it do
      expect(submit_tag).to include('class="btn btn-primary"')
      expect(submit_tag(nil, class: nil)).to_not include('class=')
      expect(submit_tag(nil, class: '')).to include('class=""')
      expect(submit_tag(nil, class: 'foo')).to include('class="foo"')
    end
  end
end
